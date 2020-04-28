import javax.sound.sampled.*;
import java.util.Arrays;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.nio.FloatBuffer;
import java.nio.ByteBuffer;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;

int[] sineTbl = { // ((byte) round(sin(i * PI / 128f) * 127f)) & 0xFF;
  0x00, 0x03, 0x06, 0x09, 0x0C, 0x10, 0x13, 0x16, 0x19, 0x1C, 0x1F, 0x22, 0x25, 0x28, 0x2B, 0x2E,
  0x31, 0x33, 0x36, 0x39, 0x3C, 0x3F, 0x41, 0x44, 0x47, 0x49, 0x4C, 0x4E, 0x51, 0x53, 0x55, 0x58,
  0x5A, 0x5C, 0x5E, 0x60, 0x62, 0x64, 0x66, 0x68, 0x6A, 0x6B, 0x6D, 0x6F, 0x70, 0x71, 0x73, 0x74,
  0x75, 0x76, 0x78, 0x79, 0x7A, 0x7A, 0x7B, 0x7C, 0x7D, 0x7D, 0x7E, 0x7E, 0x7E, 0x7F, 0x7F, 0x7F,
  0x7F, 0x7F, 0x7F, 0x7F, 0x7E, 0x7E, 0x7E, 0x7D, 0x7D, 0x7C, 0x7B, 0x7A, 0x7A, 0x79, 0x78, 0x76,
  0x75, 0x74, 0x73, 0x71, 0x70, 0x6F, 0x6D, 0x6B, 0x6A, 0x68, 0x66, 0x64, 0x62, 0x60, 0x5E, 0x5C,
  0x5A, 0x58, 0x55, 0x53, 0x51, 0x4E, 0x4C, 0x49, 0x47, 0x44, 0x41, 0x3F, 0x3C, 0x39, 0x36, 0x33,
  0x31, 0x2E, 0x2B, 0x28, 0x25, 0x22, 0x1F, 0x1C, 0x19, 0x16, 0x13, 0x10, 0x0C, 0x09, 0x06, 0x03,
  0x00, 0xFD, 0xFA, 0xF7, 0xF4, 0xF0, 0xED, 0xEA, 0xE7, 0xE4, 0xE1, 0xDE, 0xDB, 0xD8, 0xD5, 0xD2,
  0xCF, 0xCD, 0xCA, 0xC7, 0xC4, 0xC1, 0xBF, 0xBC, 0xB9, 0xB7, 0xB4, 0xB2, 0xAF, 0xAD, 0xAB, 0xA8,
  0xA6, 0xA4, 0xA2, 0xA0, 0x9E, 0x9C, 0x9A, 0x98, 0x96, 0x95, 0x93, 0x91, 0x90, 0x8F, 0x8D, 0x8C,
  0x8B, 0x8A, 0x88, 0x87, 0x86, 0x86, 0x85, 0x84, 0x83, 0x83, 0x82, 0x82, 0x82, 0x81, 0x81, 0x81,
  0x81, 0x81, 0x81, 0x81, 0x82, 0x82, 0x82, 0x83, 0x83, 0x84, 0x85, 0x86, 0x86, 0x87, 0x88, 0x8A,
  0x8B, 0x8C, 0x8D, 0x8F, 0x90, 0x91, 0x93, 0x95, 0x96, 0x98, 0x9A, 0x9C, 0x9E, 0xA0, 0xA2, 0xA4,
  0xA6, 0xA8, 0xAB, 0xAD, 0xAF, 0xB2, 0xB4, 0xB7, 0xB9, 0xBC, 0xBF, 0xC1, 0xC4, 0xC7, 0xCA, 0xCD,
  0xCF, 0xD2, 0xD5, 0xD8, 0xDB, 0xDE, 0xE1, 0xE4, 0xE7, 0xEA, 0xED, 0xF0, 0xF4, 0xF7, 0xFA, 0xFD
};

public class NativeSoundPlayer extends Thread {
  boolean debug = false;
  private CraftSampler sampler;
  private SourceDataLine line;
  private boolean finished=false;
  private byte[] internalBuffer;
  private int intBufSamples;
  private int extBufSamples;
  private AudioFormat format;
  private AudioFormat formatRecord;
  private ByteArrayOutputStream recordBuffer;
  private File recordFile;
  private boolean doRecord=false;
  public NativeSoundPlayer(CraftMusic mus, int sampleRate, File recFile, float outSpeedMult) {
    recordFile=recFile;
    if (recordFile != null) doRecord = true;
    extBufSamples = sampleRate / 10; // 100ms/6frame buffer
    intBufSamples = sampleRate / 20; // 50ms/3frame chunk size
    internalBuffer=new byte[intBufSamples * 2 * 2];
    sampler = new CraftSampler(mus);
    sampler.initSampleRate(sampleRate);
    try {
      format = new AudioFormat((float)sampleRate * outSpeedMult, 8 * 2, 2, true, false);
      formatRecord = new AudioFormat((float)sampleRate, 8 * 2, 2, true, false);
      line = (SourceDataLine) AudioSystem.getSourceDataLine(format);
      line.open(format, extBufSamples * 2 * 2);
    } 
    catch(LineUnavailableException e) {
      println("Couldn't get audio output!");
      finished = true;
      return;
    }
  }
  public void open() {
    if (finished) return;
    if (doRecord) {
      recordBuffer = new ByteArrayOutputStream();
      println("Beginning soundtrack recording");
    }
    start();
    if (debug) println("Audio output started");
  }
  public void close() {
    if (finished) return;
    finished=true;
    if (recordFile!=null) {
      println("Saving soundtrack recording...");
      ByteArrayInputStream b_in = new ByteArrayInputStream(recordBuffer.toByteArray());
      AudioInputStream ais = new AudioInputStream(b_in, formatRecord, recordBuffer.size());
      try {
        AudioSystem.write(ais, AudioFileFormat.Type.WAVE, recordFile);
      }
      catch(IOException e) {
        println("Couldn't write to file " + recordFile.getAbsolutePath());
      }
    }
    if (debug) println("Audio output finished");
  }
  public void run() {
    if (finished) return;
    line.start();
    while (!finished) {
      int offset = 0;
      // Generate sample buffer
      for (int i = 0; i < intBufSamples; i++) {
        short sampleL = (short)(int)min(max(-32768, round(32767 * sampler.getOutputSample())), 32767);
        short sampleR = sampleL;
        internalBuffer[offset++] = (byte)(sampleL >> 0);
        internalBuffer[offset++] = (byte)(sampleL >> 8);
        internalBuffer[offset++] = (byte)(sampleR >> 0);
        internalBuffer[offset++] = (byte)(sampleR >> 8);
      }
      // Copy internal buffer to record buffer
      if (doRecord) {
        recordBuffer.write(internalBuffer, 0, internalBuffer.length);
      }
      // Wait for space to become available
      while (line.available() < intBufSamples << 2) {
        try {
          Thread.sleep(1);
        }
        catch (InterruptedException nom) {
        }
      }
      line.write(internalBuffer, 0, internalBuffer.length);
    }
    line.flush();
    line.stop();
    line.close();
    line = null;
  }
  public boolean musicFinished() {
    return sampler.musicFinished();
  }
}

public class CraftSampler {
  boolean antiAlias=false;
  boolean filter=false;
  float craftSampleRate = 525f * 20000000f / 333375f;
  float sampleRate;
  float sampleRateInverse;
  float lastCraftSample=0;
  float partialSample;
  float relativeSampleRate;
  CraftMusic musicInstance;
  OutputFilter outFilter;
  int finishedTime=0;
  public CraftSampler(CraftMusic music) {
    musicInstance=music;
    outFilter = new OutputFilter();
    // Calculated by rough impedance 1k, C=10uF
    outFilter.setDcRC(0.01); // RC constant for (high pass) DC filter
    // Tweaked by ear and by comparing waveforms to match the original recording
    outFilter.setLpRC(0.00175); // RC constant for implicit low pass filter
    outFilter.setLpFactor(0.0); // How much of the low pass to mix in
    outFilter.setAmplitude(0.875); // How loud to make the final output (roughly match high quality mode)
  }
  public void initSampleRate(float sr) {
    sampleRate = sr;
    sampleRateInverse = 1f / sr;
    relativeSampleRate = craftSampleRate * sampleRateInverse;
    outFilter.setDt(sampleRateInverse);
  }
  public float getOutputSample() {
    float partialSampleLast = partialSample;
    partialSample += relativeSampleRate;
    float antiAliasSample = lastCraftSample;
    if (partialSample >= 1) {
      float remaining = 1 - partialSampleLast;
      float totalSamples = remaining;
      antiAliasSample = lastCraftSample * remaining;
      for (int i=1; i<=partialSample-1; i++) {
        float intermediate = musicInstance.getSample();
        antiAliasSample += intermediate;
        totalSamples++;
      }
      partialSample -= floor(partialSample);
      lastCraftSample = musicInstance.getSample();
      antiAliasSample += lastCraftSample * partialSample;
      totalSamples += partialSample;
      antiAliasSample /= totalSamples;
    }
    finishedTime++;
    if (!musicInstance.flag_songend) finishedTime = 0;
    float out = antiAlias ? antiAliasSample : lastCraftSample;
    float outFiltered = outFilter.doSample(out);
    float ret = filter ? outFiltered : out;
    return ret;
  }
  public boolean musicFinished() {
    return finishedTime >= sampleRate;
  }
}

public class CraftMusic {
  int[] swingTable = {1,1,1,1,0,1,1,1,1,0,2,1,1,2,1,1};
  int swingIndex = 0;
  boolean debug = false;
  boolean highDac = false;
  int precalcSamples = 0;

  private byte[] trackdata;
  private byte[] instrdata;
  private byte instrtab_pre;
  private byte[] instrtab;
  private byte[] tracktab;
  private byte[] song;
  private int[] freqTbl;
  private int songPointer = 0;
  private int trackPos = 0;
  private int trackTimer = 0;
  private int videoLine = 0;
  private int vblankTime = 0;
  // Mode defines the entry point for sample generation
  // 0 = vblank timer interrupt, 1 = vblank timer syncing, 2 = video lines drawing
  private int mode = 0;
  private boolean enableSwing = false;

  protected int[] c_tptr = new int[3]; // Track number (not accurate)
  protected int[] c_tbits = new int[3]; // Track bit pointer (not accurate)
  protected int[] c_lasti = new int[3]; // Last set instrument pointer
  protected int[] c_iptr = new int[3]; // Instrument current pointer
  protected int[] c_iloop = new int[3]; // Instrument loop pointer
  protected int[] c_timer = new int[3]; // Instrument wait timer
  protected int[] c_tnote = new int[3]; // Track/original note
  protected int[] c_inote = new int[3]; // Instrument/transpose note
  protected int[] c_bendd = new int[3]; // Bend delta
  volatile protected int[] c_vold = new int[3]; // Volume delta
  protected int[] c_vpos = new int[3]; // Vibrato position
  protected int[] c_vrate = new int[3]; // Vibrato rate
  protected int[] c_vdepth = new int[3]; // Vibrato depth
  protected int[] c_freq = new int[3]; // Frequency
  volatile protected int[] c_vol = new int[3]; // Volume
  volatile protected int[] c_phase = new int[3]; // Phase (not in original)
  protected int n_vol = 0; // Noise volume
  protected int n_rel = 0; // Noise release
  protected int n_register = 0; // Noise generator register
  protected boolean flag_songend = false;
  protected boolean[] mutes = new boolean[4];
  protected ArrayList<Float> sampleQueue = new ArrayList<Float>();
  protected float lastAvailableSample;

  public CraftMusic(String hexTrackdata, String hexInstrdata, String hexInstrtabPre, String hexInstrtab, String hexTracktab, String hexSong, String hexFreq) {
    trackdata = bytesFromHexString(hexTrackdata);
    instrdata = bytesFromHexString(hexInstrdata);
    instrtab_pre = bytesFromHexString(hexInstrtabPre)[0];
    instrtab = bytesFromHexString(hexInstrtab);
    tracktab = bytesFromHexString(hexTracktab);
    song = bytesFromHexString(hexSong);
    byte[] freqTblBytes = bytesFromHexString(hexFreq);
    freqTbl = new int[129];
    if (freqTblBytes.length < 258) {
      println("Frequency table missing tail data, results may be inaccurate.");
    }
    for (int i = 0; i < min(129, freqTblBytes.length >> 1); i++) {
      freqTbl[i] = (freqTblBytes[i << 1] & 0xFF) | ((freqTblBytes[(i << 1) | 1] & 0xFF) << 8);
      //println("freqTbl["+hex(i,3)+"] = "+hex(freqTbl[i],4));
    }
    //for(int i=0; i<sineTbl.length; i++) sineTbl[i] = 0; // HACK TO DISABLE VIBRATO
    reset();
  }
  public void reset() {
    n_register = 0x0001;
    for(int i = 0; i < precalcSamples; i++) {
      soundroutine();
    }
    songPointer = 0;
    trackPos = 0;
    // Sync entry point is important!
    videoLine = 0;
    vblankTime = 0;
    mode = 2;
    for(int ch = 0; ch < 3; ch++) {
      c_vpos[ch] = 0;
    }
    // TODO: reset other sound registers
    flag_songend = false;
    sampleQueue.clear();
  }
  private void playroutineSwing() {
    for(int i = 0; i < swingTable[swingIndex]; i++) {
      playroutine_time();
    }
    playroutine_sound();
    swingIndex++;
    if(swingIndex >= swingTable.length) swingIndex = 0;
  }
  private void playroutine_time() {
    if (!flag_songend) { // up to play_sound
      trackTimer--;
      if (trackTimer < 0) { // up to play_nonewline
        trackPos--;
        if (trackPos < 0) { // up to play_nonewpos
          // new track
          // loop through channels
          for (int ch = 0; ch < 3; ch++) {
            int songLineData = readBits(song, songPointer, 6);
            songPointer += 6;
            int newTrack = songLineData & 0x3F;
            if (songLineData != 0) {
              newTrack--;
              int trackStructIndex = 3 * (newTrack >>> 1);
              int trackStructFirst = (tracktab[trackStructIndex] & 0xFF) | ((tracktab[trackStructIndex + 1] & 0xF0) << 4);
              int trackStructSecond = ((tracktab[trackStructIndex + 1] & 0x0F) << 8) | (tracktab[trackStructIndex + 2] & 0xFF);
              c_tbits[ch] = (((newTrack & 1) == 0) ? trackStructFirst : trackStructSecond) << 3;
              newTrack += 1; // Add some offset so the line player knows there's a track
            }
            c_tptr[ch] = newTrack;
          }
          trackPos = 31;
        }
        // loop through channels
        for (int ch = 0; ch < 3; ch++) {
          if (c_tptr[ch] != 0) { // up to play_notrack
            int hasInstrumentNote = readBits(trackdata, c_tbits[ch], 2);
            c_tbits[ch] += 2;
            if ((hasInstrumentNote & 2) > 0) { // Instrument
              int instrument = readBits(trackdata, c_tbits[ch], 5);
              c_tbits[ch] += 5;
              int instrumentPtr = 0;
              if (instrument > 0 && instrument <= instrtab.length) instrumentPtr = instrtab[instrument - 1] & 0xFF;
              else if (instrument == 0) instrumentPtr = instrtab_pre;
              c_lasti[ch] = instrumentPtr;
              c_iptr[ch] = instrumentPtr;
              c_iloop[ch] = 0;
              c_timer[ch] = 0;
              if (debug) println("CH" + ch + " Instrument set 0x" + hex(instrument, 2) + " (ptr 0x" + hex(instrumentPtr, 2) + ")");
            }
            if ((hasInstrumentNote & 1) > 0) { // Note
              int note = readBits(trackdata, c_tbits[ch], 7);
              c_tbits[ch] += 7;
              note = constrain(note, 1, 127);
              note--;
              // plonk
              c_vol[ch] = 0;
              c_iptr[ch] = c_lasti[ch];
              if (debug) println("CH" + ch + " Instrument trigger ptr 0x" + hex(c_lasti[ch], 2));
              c_iloop[ch] = 0;
              c_timer[ch] = 0;
              c_tnote[ch] = note;
              c_inote[ch] = note << 8;
              c_bendd[ch] = 0;
              c_vold[ch] = 0;
              c_vrate[ch] = 24;
              c_vdepth[ch] = 0;
            }
          }
        }
        trackTimer = 4 - 1; // tempo - 1
      }
    }
  }
  private void playroutine_sound() {
    // play_sound
    for (int ch = 0; ch < 3; ch++) {
      int timer;
      while (true) {
        int instrumentPointer = c_iptr[ch];
        timer = c_timer[ch];
        instrumentPointer--; // Offset by 1 for hardcoded instrument 0 at iptr=0
        if (instrumentPointer >= 0 && timer == 0) {
          int commandByte = instrdata[instrumentPointer] & 0xFF;
          instrumentPointer += 2; // Increment, accounting for offset
          c_iptr[ch] = instrumentPointer;
          runCommand(ch, commandByte);
        } else break;
      }
      timer--;
      boolean c = timer<0;
      timer &= 0xFF;
      if (!c) {
        c_timer[ch] = timer;
      }
      int note = c_inote[ch]; // here's our note value in 8.8 format
      int vibPos = c_vpos[ch];
      int vibSine = sineTbl[vibPos] & 0xFF;
      if (vibSine >= 0x80) { // Make signed
        vibSine |= 0xFF00;
      }
      int vibDepth = c_vdepth[ch];
      int vibAmount = (vibSine * vibDepth) & 0xFFFF; // r1:r0 is wanted vibrato offset times 64
      int strayCarry = vibAmount >>> 14; // Emualte quirk of over-optimised ASM code
      // NOTE: The stray carry ends up getting discarded anyway, no need to emulate!
      if (vibAmount >= 0x8000) {
        vibAmount |= 0xFF0000;
      }
      vibAmount = ((vibAmount << 2) & 0xFFFFFC) | strayCarry;

      note += vibAmount >>> 8; // update note
      note &= 0xFFFF;
      vibPos += c_vrate[ch];
      vibPos &= 0xFF;
      c_vpos[ch] = vibPos;
      int freqIndex = note >>> 8;
      // In source, index is a pointer offset to 2-byte data, so 128 possible indices
      freqIndex &= 0x7F;
      //if(freqIndex > 82) println("FREQBUG "+freqIndex);
      int freq = freqTbl[freqIndex];
      freq &= 0xFFFF;
      int freqDist = (freqTbl[freqIndex + 1] - freq) & 0xFFFF;
      int noteLow = note & 0xFF;
      int multResult = (freqDist >>> 8) * noteLow; // product of hi(dist) and lo(note)
      multResult += ((freqDist & 0xFF) * noteLow) >>> 8; // product of lo(dist) and lo(note)
      freq += multResult;
      freq &= 0xFFFF;
      note = c_inote[ch];
      int bendDelta = c_bendd[ch] & 0xFF;
      if (bendDelta >= 0x80) {
        bendDelta |= 0xFF00;
      }
      note = (note + bendDelta + bendDelta) & 0xFFFF;
      if (note >= 0x8000) {
        note = 0;
      }
      c_inote[ch] = note;

      int volume = c_vol[ch];
      int volumeDelta = c_vold[ch];
      volume += volumeDelta;
      volume &= 0xFF;
      if ((volume & 0x80) > 0) { // clamp negative to 0
        //if(ch==2)println("VOLNEG CH"+ch);
        volume = 0;
      }
      if ((volume & 0x20) > 0) { // clamp to max
        volume = 31;
      }

      // stop oscillator if silent
      if (volume == 0) {
        freq = 0;
      }

      c_freq[ch] = freq;
      c_vol[ch] = volume;
    }
    n_vol = (n_vol - n_rel) & 0xFF;
    if (n_vol >= 0x80) { // clamp negative to 0
      n_vol = 0;
    }
  }

  void runCommand(int ch, int cmd) {
    //boolean debug = true; // override
    if (debug) print("CH" + ch + " Command 0x" + hex(cmd, 2)+": ");
    int param = cmd & 0xF;
    int paramHi = param << 4;
    cmd >>>= 4;
    switch(cmd) {
    case 0:
      c_iptr[ch] = c_iloop[ch];
      if (debug) {
        print("GOLP");
        if (c_iptr[ch] == 0) print(" (stop)");
      }
      break;
    case 1:
      c_iloop[ch] = c_iptr[ch];
      if (debug) print("SELP (at 0x"+hex(c_iptr[ch], 2)+")");
      break;
      // 2 invalid
    case 3:
      c_bendd[ch] = paramHi;
      if (debug) print("BNDD 0x"+hex(c_bendd[ch], 2));
      break;
    case 4:
      c_vrate[ch] = (paramHi >>> 1) & 0x7F;
      if (debug) print("VIBR 0x"+hex(c_vrate[ch], 2));
      break;
    case 5:
      c_vdepth[ch] = paramHi;
      if (debug) print("VIBD 0x"+hex(c_vdepth[ch], 2));
      break;
    case 6:
      c_vol[ch] = param << 1;
      if (debug) print("VOLS 0x"+hex(c_vol[ch], 2));
      break;
    case 7:
      int paramSigned = param | ((param & 0x08) > 0 ? 0xF0 : 0);
      c_vold[ch] = paramSigned;
      if (debug) print("VOLD 0x"+hex(c_vold[ch], 2));
      break;
      // 8 invalid
    case 9:
      int vnew = param;
      vnew <<= 1;
      vnew &= 0x18;
      int rnew = 4 - (param & 3);
      if (n_vol == 0 || rnew < n_rel) {
        n_vol = vnew;
        n_rel = rnew;
        if (debug) print("NOIS V=0x"+hex(n_vol, 2)+" R=0x"+hex(n_rel, 2));
      } else if (debug) print("NOIS (no change)");
      break;
    case 10:
      c_inote[ch] &= 0x00FF;
      c_inote[ch] |= ((c_tnote[ch] + param) & 0xFF) << 8;
      if (debug) print("TPNU 0x" + hex(param, 2) + " (to 0x" + hex(c_inote[ch], 4) + ")");
      break;
    case 11:
      c_inote[ch] &= 0x00FF;
      c_inote[ch] |= ((c_tnote[ch] - param) & 0xFF) << 8;
      if (debug) print("TPND 0x" + hex(param, 2) + " (to 0x" + hex(c_inote[ch], 4) + ")");
      break;
      // 12 invalid
    case 13:
      c_timer[ch] = param;
      if (debug) print("WAIT 0x" + hex(param, 2));
      break;
    case 14:
      c_timer[ch] = paramHi;
      if (debug) print("WLNG 0x" + hex(paramHi, 2));
      break;
    case 15:
    default:
      flag_songend = true;
      if (debug) {
        if (cmd == 15) print("ENDS");
        else print("ILLEGAL/ENDS");
      }
      break;
    }
    if (debug) {
      println();
      //println("-> CMD="+hex(cmd,2)+", Param="+hex(param,2)+", ParamHi="+hex(paramHi,2));
    }
  }
  private void soundroutine() {
    for (int i = 0; i < 3; i++) {
      c_phase[i] = (c_phase[i] + c_freq[i]) & 0xFFFF;
    }

    n_register <<= 1;
    n_register &= 0xFFFF;
    if ((n_register & 0x8000) > 0) n_register ^= 1;
    if ((n_register & 0x4000) > 0) n_register ^= 1;

    int samp = 0;

    // Ch0 - 25% pulse
    int phase0hi = c_phase[0] >>> 8;
    int wave0 = (phase0hi << 1) & phase0hi;
    int c0samp = c_vol[0];
    if (wave0 >= 0x80) c0samp = -c0samp;
    if (!mutes[0]) samp += c0samp;

    // Ch1 - 50% pulse
    int phase1hi = c_phase[1] >>> 8;
    int c1samp = c_vol[1];
    if (phase1hi >= 0x80) c1samp = -c1samp;
    if (!mutes[1]) samp += c1samp;

    // Ch2 - Triangle
    int c2samp = c_phase[2] >>> 8;
    if (c2samp >= 0x80) c2samp = 0xFF - c2samp;
    c2samp >>>= 1;
    if (!mutes[2]) samp += c2samp;

    int c3samp = n_vol;
    if (n_register >= 0x8000) c3samp = (-c3samp) & 0xFF;
    if (!mutes[3]) samp += c3samp;

    samp -= 32 + 128;
    samp &= 0xFF;
    int sampMax = 0xFF;
    if (!highDac) {
      samp >>>= 2;
      sampMax >>>= 2;
    }

    sampleQueue.add(map(samp, 0, sampMax, -1, 1));
  }
  public float getSample() {
    if(sampleQueue.isEmpty())
    switch(mode) {
    case 0: // Timer1 interrupt sync
    default:
      soundroutine();
      if (vblankTime >= 43) {
        mode = 1;
      } else vblankTime++;
      break;
    case 1: // Final sync with Timer1, start video lines
      videoLine = 0;
      soundroutine();
      mode = 2;
      break;
    case 2: // End of video line
      videoLine++;
      if (videoLine >= 480) {
        soundroutine();
        vblankTime = 0;
        mode = 0;
        if(enableSwing) {
          playroutineSwing();
        } else {
          playroutine_time();
          playroutine_sound();
        }
        break;
      }
      soundroutine();
      break;
    }
    if(!sampleQueue.isEmpty()) lastAvailableSample = sampleQueue.remove(0);
    return lastAvailableSample;
  }
  public void enableSwing(boolean enable) {
    enableSwing = enable;
  }
  private byte[] bytesFromHexString(String s) {
    byte[] b = new byte[(s.length() + 1) >> 1];
    for (int i = 0; i < b.length; i++) b[i] = (byte)Integer.parseInt(s.substring(i + i, i + i + 2), 16);
    return b;
  }
  private int readBits(byte[] data, int firstBit, int len) {
    int value = 0;
    int byteIndex;
    for (int i = firstBit; i < firstBit + len; i++) {
      value <<= 1;
      byteIndex = i >>> 3;
      if (byteIndex < data.length) value |= (data[byteIndex] >> (7 - (i & 7))) & 1;
    }
    return value;
  }
}

class OutputFilter {
  float dt=0;
  float dcRC=0;
  float dcA=0;
  float dcYLast=0;
  float dcXLast=0;
  float lpRC=0;
  float lpA=0;
  float lpYLast=0;
  float lpFactor=0;
  float amplitude=0;
  void setDt(float dt) {
    this.dt=dt;
    if (dcRC <=0 || dt <= 0)dcA=0;
    else dcA=dcRC/(dcRC+dt);
    if (lpRC <=0 || dt <= 0)lpA=0;
    else lpA=dt/(lpRC+dt);
  }
  void setDcRC(float RC) {
    this.dcRC=RC;
    if (dcRC <= 0 || dt <= 0)dcA=0;
    else dcA=dcRC/(dcRC+dt);
  }
  void setLpRC(float RC) {
    this.lpRC=RC;
    if (lpRC <=0 || dt <= 0)lpA=0;
    else lpA=dt/(lpRC+dt);
  }
  void setLpFactor(float lpFactor) {
    this.lpFactor=min(max(0, lpFactor), 1);
  }
  void setAmplitude(float amplitude) {
    this.amplitude=min(max(0, amplitude), 1);
  }
  private float sampleDc(float x) {
    float y = dcA*(dcYLast+x-dcXLast);
    dcXLast=x;
    dcYLast=y;
    return y;
  }
  float doSample(float x) {
    float xd = sampleDc(x);
    float y = (lpA * xd) + ((1-lpA) * lpYLast);
    lpYLast=y;
    return (xd+(y*lpFactor))*amplitude;
  }
}
