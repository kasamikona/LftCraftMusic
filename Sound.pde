int[] freqTbl = {
  0x004a, 0x004e, 0x0053, 0x0058, 0x005d, 0x0063, 0x0068, 0x006f, 
  0x0075, 0x007c, 0x0084, 0x008c, 0x0094, 0x009d, 0x00a6, 0x00b0, 
  0x00bb, 0x00c6, 0x00d1, 0x00de, 0x00eb, 0x00f9, 0x0108, 0x0118, 
  0x0128, 0x013a, 0x014d, 0x0161, 0x0176, 0x018c, 0x01a3, 0x01bc, 
  0x01d7, 0x01f3, 0x0211, 0x0230, 0x0251, 0x0275, 0x029a, 0x02c2, 
  0x02ec, 0x0318, 0x0347, 0x0379, 0x03ae, 0x03e6, 0x0422, 0x0461, 
  0x04a3, 0x04ea, 0x0535, 0x0584, 0x05d8, 0x0631, 0x068f, 0x06f3, 
  0x075d, 0x07cd, 0x0844, 0x08c2, 0x0947, 0x09d4, 0x0a6a, 0x0b08, 
  0x0bb0, 0x0c62, 0x0d1f, 0x0de7, 0x0eba, 0x0f9b, 0x1088, 0x1184, 
  0x128e, 0x13a9, 0x14d4, 0x1611, 0x1761, 0x18c5, 0x1a3e, 0x1bce, 
  0x1d75, 0x1f36, 0x2111, 0x2308
};

int[] sineTblBytes = { // ((byte) round(sin(i * PI / 128f) * 127f)) & 0xFF;
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

int[] sineTbl;
{
  sineTbl = new int[sineTblBytes.length];
  for(int i = 0; i < 256; i++) sineTbl[i] = (byte) sineTblBytes[i];
}


public class CraftUgen extends UGen {
  private CraftSampler sampler;
  public CraftUgen(CraftMusic mus) {
    sampler=new CraftSampler(mus);
  }
  public void sampleRateChanged() {
    sampler.initSampleRate(sampleRate());
  }
  public void uGenerate(float[] channels) {
    float sample=sampler.getOutputSample();
    for (int i=channels.length-1; i>=0; i--) channels[i] = sample;
  }
}

public class CraftSampler {
  int craftSamplesPerFrame=525;
  int sampleMultiplier;
  float relativeSampleRate;
  float relativeSampleRateDivided;
  float partialSample=0;
  float lastCraftSample=0;
  CraftMusic musicInstance;
  public CraftSampler(CraftMusic music) {
    musicInstance=music;
  }
  public void initSampleRate(float sr) {
    float craftFrameRate = 20000000/333375f;
    float craftSampleRate = craftFrameRate*craftSamplesPerFrame;
    relativeSampleRate = craftSampleRate/sr;
  }
  public float getOutputSample() {
    float partialSampleLast = partialSample;
    partialSample += relativeSampleRate;
    float ret = lastCraftSample;
    if (partialSample >= 1) {
      float remaining = 1 - partialSampleLast;
      float totalSamples = remaining;
      ret = lastCraftSample * remaining;
      for (int i=1; i<=partialSample-1; i++) {
        float intermediate = musicInstance.getSample();
        ret += intermediate;
        totalSamples++;
      }
      partialSample -= floor(partialSample);
      lastCraftSample = musicInstance.getSample();
      ret += lastCraftSample * partialSample;
      totalSamples += partialSample;
      ret /= totalSamples;
    }
    return lastCraftSample;
    //return ret;
  }
}

public class CraftMusic {
  
    boolean debug=false;
  private byte[] trackdata;
  private byte[] instrdata;
  private byte instrtab_pre;
  private byte[] instrtab;
  private byte[] tracktab;
  private byte[] song;
  private int videoLine=0;
  private int songPointer=0;
  private int trackPos=0;
  private int trackTimer=0;

  protected int[] c_tptr = new int[3]; // Track number (not accurate)
  protected int[] c_tbits = new int[3]; // Track bit pointer (not accurate)
  protected int[] c_lasti = new int[3]; // Last set instrument pointer
  protected int[] c_iptr = new int[3]; // Instrument current pointer
  protected int[] c_iloop = new int[3]; // Instrument loop pointer
  protected int[] c_timer = new int[3]; // Instrument wait timer
  protected int[] c_tnote = new int[3]; // Track/original note
  protected int[] c_inote = new int[3]; // Instrument/transpose note
  protected int[] c_bendd = new int[3]; // Bend delta
  protected int[] c_vold = new int[3]; // Volume delta
  protected int[] c_vpos = new int[3]; // Vibrato position
  protected int[] c_vrate = new int[3]; // Vibrato rate
  protected int[] c_vdepth = new int[3]; // Vibrato depth
  protected int[] c_freq = new int[3]; // Frequency
  protected int[] c_vol = new int[3]; // Volume
  protected int[] c_phase = new int[3]; // Phase (not in original)
  protected int n_vol = 0; // Noise volume
  protected int n_rel = 0; // Noise release
  protected int n_register = 0; // Noise generator register
  protected boolean flag_songend = false;
  protected boolean[] mutes = new boolean[4];

  public CraftMusic(String hexTrackdata, String hexInstrdata, String hexInstrtabPre, String hexInstrtab, String hexTracktab, String hexSong) {
    trackdata = bytesFromHexString(hexTrackdata);
    instrdata = bytesFromHexString(hexInstrdata);
    instrtab_pre = bytesFromHexString(hexInstrtabPre)[0];
    instrtab = bytesFromHexString(hexInstrtab);
    tracktab = bytesFromHexString(hexTracktab);
    song = bytesFromHexString(hexSong);
    reset();
  }
  public void reset() {
    songPointer = 0;
    trackPos = 0;
    videoLine = 0;
    n_register = 0x0001;
    // TODO: reset other sound registers
    flag_songend = false;
  }
  private void playroutine() {
    if(!flag_songend) { // up to play_sound
      trackTimer--;
      if(trackTimer < 0) { // up to play_nonewline
        trackPos--;
        if(trackPos < 0) { // up to play_nonewpos
          // new track
          // loop through channels
          for(int ch = 0; ch < 3; ch++) {
            int songLineData = readBits(song, songPointer, 6);
            songPointer += 6;
            int newTrack = songLineData & 0x3F;
            if(songLineData != 0) {
              newTrack--;
              int trackStructIndex = 3 * (newTrack >>> 1); //(newTrack & 0x3E) + (newTrack >> 1); // 3 * (trackNum >> 1)
              int trackStructFirst = (tracktab[trackStructIndex] & 0xFF) | ((tracktab[trackStructIndex + 1] & 0xF0) << 4);
              int trackStructSecond = ((tracktab[trackStructIndex + 1] & 0x0F) << 8) | (tracktab[trackStructIndex + 2] & 0xFF);
              c_tbits[ch] = (((newTrack & 1) == 0) ? trackStructFirst : trackStructSecond) << 3;
              newTrack += 1; // Add some non-null offset so the line player knows there's a track
            }
            c_tptr[ch] = newTrack;
          }
          trackPos = 31;
        }
        // loop through channels
        for(int ch = 0; ch < 3; ch++) {
          //if(ch != 1) continue;
          if(c_tptr[ch] != 0) { // up to play_notrack
            int hasInstrumentNote = readBits(trackdata, c_tbits[ch], 2);
            c_tbits[ch] += 2;
            if ((hasInstrumentNote & 2) > 0) { // Instrument
              int instrument = readBits(trackdata, c_tbits[ch], 5);
              c_tbits[ch] += 5;
              int instrumentPtr = 0;
              if(instrument > 0 && instrument < instrtab.length) instrumentPtr = instrtab[instrument - 1] & 0xFF;
              else if(instrument == 0) instrumentPtr = instrtab_pre;
              c_lasti[ch] = instrumentPtr;
              c_iptr[ch] = instrumentPtr;
              c_iloop[ch] = 0;
              c_timer[ch] = 0;
              if(debug) println("CH" + ch + " Instrument set 0x" + hex(instrument, 2) + " (ptr 0x" + hex(instrumentPtr, 2) + ")");
            }
            if ((hasInstrumentNote & 1) > 0) { // Note
              int note = readBits(trackdata, c_tbits[ch], 7);
              note--;
              c_tbits[ch] += 7;
              // plonk
              c_vol[ch] = 0;
              c_iptr[ch] = c_lasti[ch];
              if(debug) println("CH" + ch + " Instrument trigger ptr 0x" + hex(c_lasti[ch], 2));
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
        trackTimer = 3; // tempo - 1
      }
    }
    // play_sound
    for(int ch = 0; ch < 3; ch++) {
      int timer;
      while(true) {
        int instrumentPointer = c_iptr[ch] - 1;
        timer = c_timer[ch];
        if(instrumentPointer < 0) break;
        if(timer != 0) break;
        int commandByte = instrdata[instrumentPointer] & 0xFF;
        instrumentPointer += 2;
        c_iptr[ch] = instrumentPointer;
        runCommand(ch, commandByte);
      }
      timer--;
      if(timer >= 0) {
        c_timer[ch] = timer;
      }
      int note = c_inote[ch]; // here's our note value in 8.8 format
    
      int vibPos = c_vpos[ch];
      int vibSine = (byte)sineTbl[vibPos];
      int vibDepth = c_vdepth[ch];
      int vibAmount = (vibSine * vibDepth)&0xFFFF; // r1:r0 is wanted vibrato offset times 64
      int strayCarry = vibAmount >>> 15; // Emualte quirk of over-optimised ASM code
      // NOTE: The stray carry ends up getting discarded anyway, no need to emulate!
      int vibAmountHigh = 0;
      if(vibAmount >= 0x8000) {
        vibAmountHigh = 255;
      }
      vibAmountHigh = (vibAmountHigh << 2) | (vibAmount >>> 14);
      vibAmount = ((vibAmount << 2) & 0xFFFF) | (strayCarry << 1);
      
      note += (vibAmountHigh << 8) | (vibAmount >> 8); // update note
      note &= 0xFFFF;
      vibPos += c_vrate[ch];
      vibPos &= 0xFF;
      c_vpos[ch] = vibPos;
      int freqIndex = note >> 8;
      int freqIndexNext = freqIndex + 1;
      // Added to prevent array length overflow - extreme notes won't glitch
      int maxIndex = freqTbl.length - 1;
      if(freqIndex >= maxIndex - 1) {
        if(freqIndex >= maxIndex) {
          freqIndex = maxIndex;
        }
        freqIndexNext = maxIndex;
      }
      if(freqIndex < 0) {
        freqIndex = 0;
        freqIndexNext = 0;
      }
      int freq = freqTbl[freqIndex];
      int freqDist = freqTbl[freqIndexNext] - freq;
      int noteLow = note & 0xFF;
      int multResult = (freqDist >> 8) * noteLow; // r1:r0 is product of hi(dist) and lo(note)
      multResult += ((freqDist & 0xFF) * noteLow) >> 8; // r1:r0 is product of lo(dist) and lo(note)
      freq += multResult;
      note = c_inote[ch];
      int bendDelta = c_bendd[ch];
      if(bendDelta >= 0x80) {
        bendDelta -= 256;
      }
      note = (note + bendDelta + bendDelta) & 0xFFFF;
      if(note >= 0x8000) {
        note = 0;
      }
      c_inote[ch] = note;
  
      int volume = c_vol[ch];
      int volumeDelta = c_vold[ch];
      volume += volumeDelta;
      volume &= 0xFF;
      if(volume >= 0x80) { // clamp negative to 0
        volume = 0;
      }
      if(volume >= 32) { // clamp to max
        volume = 31;
      }
      
      // stop oscillator if silent
      if(volume == 0) {
        freq = 0;
      }
      
      c_freq[ch] = freq;
      c_vol[ch] = volume;
    }
    n_vol = (n_vol - n_rel) & 0xFF;
    if(n_vol >= 0x80) { // clamp negative to 0
      n_vol = 0;
    }
  }
  
  void runCommand(int ch, int cmd) {
    if(debug) print("CH" + ch + " Command 0x" + hex(cmd, 2)+": ");
    int param = cmd & 0xF;
    int paramHi = param << 4;
    cmd >>>= 4;
    switch(cmd) {
    case 0:
      c_iptr[ch] = c_iloop[ch];
      if(debug) {
        print("GOLP");
        if(c_iptr[ch] == 0) print(" (stop)");
      }
      break;
    case 1:
      c_iloop[ch] = c_iptr[ch];
      if(debug) print("SELP (at 0x"+hex(c_iptr[ch], 2)+")");
      break;
      // 2 invalid
    case 3:
      c_bendd[ch] = paramHi;
      if(debug) print("BNDD 0x"+hex(c_bendd[ch], 2));
      break;
    case 4:
      c_vrate[ch] = paramHi>>>1;
      if(debug) print("VIBR 0x"+hex(c_vrate[ch], 2));
      break;
    case 5:
      c_vdepth[ch] = paramHi;
      if(debug) print("VIBD 0x"+hex(c_vdepth[ch], 2));
      break;
    case 6:
      c_vol[ch] = param << 1;
      if(debug) print("VOLS 0x"+hex(c_vol[ch], 2));
      break;
    case 7:
      c_vold[ch] = param | ((param >= 8) ? 0xF0 : 0);
      if(debug) print("VOLD 0x"+hex(c_vold[ch], 2));
      break;
      // 8 invalid
    case 9:
      int rnew = 4 - (param & 3);
      if (n_vol == 0 || n_rel > rnew) {
        n_vol = (param << 1) & 0x18;
        n_rel = rnew;
        if(debug) print("NOIS V=0x"+hex(n_vol, 2)+" R=0x"+hex(n_rel, 2));
      } else if(debug) print("NOIS (no change)");
      break;
    case 10:
      c_inote[ch] &= 0x00FF;
      c_inote[ch] |= (c_tnote[ch] + param) << 8;
      if(debug) print("TPNU 0x" + param + "( to 0x" + hex(c_inote[ch], 4) + ")");
      break;
    case 11:
      c_inote[ch] &= 0x00FF;
      c_inote[ch] |= (c_tnote[ch] - param) << 8;
      if(debug) print("TPND 0x" + param + "( to 0x" + hex(c_inote[ch], 4) + ")");
      break;
      // 12 invalid
    case 13:
      c_timer[ch] = param;
      if(debug) print("WAIT 0x"+hex(param, 2));
      break;
    case 14:
      c_timer[ch] = paramHi;
      if(debug) print("WAIT 0x"+hex(paramHi, 2));
      break;
    case 15:
    default:
      flag_songend = true;
      if(debug) {
        if(cmd == 15) print("ENDS");
        else print("ILLEGAL/ENDS");
      }
      break;
    }
    if(debug) println();
  }
  public float getSample() {
    videoLine++;
    if (videoLine >= 525) videoLine = 0;
    if (videoLine == 0) playroutine();

    for (int i = 0; i < 3; i++) {
      c_phase[i] = (c_phase[i] + c_freq[i]) & 0xFFFF;
    }
    
    n_register += n_register;
    if((n_register & 0x8000) > 0) n_register ^= 1;
    if((n_register & 0x4000) > 0) n_register ^= 1;
    
    float mvol = 0.4;
    int samp = 0;

    // Ch0 - 25% pulse
    int phase0hi = c_phase[0] >>> 8;
    int wave0 = phase0hi & (phase0hi << 1);
    int c0samp = c_vol[0];
    if(wave0 >= 0x80) c0samp = -c0samp;
    if(!mutes[0]) samp += c0samp;

    // Ch1 - 50% pulse
    int phase1hi = c_phase[1] >>> 8;
    int c1samp = c_vol[1];
    if(phase1hi >= 0x80) c1samp = -c1samp;
    if(!mutes[1]) samp += c1samp;

    // Ch2 - Triangle
    int c2samp = c_phase[2] >>> 8;
    if(c2samp >= 0x80) c2samp = 0xFF - c2samp;
    c2samp >>>= 1;
    if(!mutes[2]) samp += c2samp;
    
    int c3samp = n_vol;
    if(n_register >= 0x8000) c3samp = (-c3samp) & 0xFF;
    if(!mutes[3]) samp += c3samp;

    samp -= 32 + 128;
    samp &= 0xFF;
    int sampMax = 0xFF;
    //samp >>>= 2;
    //sampMax >>>= 2;

    return map(samp, 0, sampMax, -mvol, mvol);
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
