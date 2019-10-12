CraftMusic cm;
NativeSoundPlayer nsp;

int sampleRate = 44100;
boolean recordOutput = true;
float outSpeedMult = 4;

void setup() {
  size(256, 256);
  background(0);
  cm = new CraftMusic(m_trackdata, m_instrdata, m_instrtab_pre, m_instrtab, m_tracktab, m_song, m_freq);
  cm.mutes[0] = false;
  cm.mutes[1] = false;
  cm.mutes[2] = false;
  cm.mutes[3] = false;
  nsp = new NativeSoundPlayer(cm, sampleRate, recordOutput ? new File(sketchPath("soundtrack.wav")):null, outSpeedMult);
  nsp.open();
}
void draw() {
  background(0);
  text("Note0 "+hex(cm.c_inote[0],4),0,16);
  text("Note1 "+hex(cm.c_inote[1],4),0,32);
  text("Note2 "+hex(cm.c_inote[2],4),0,48);
  if(nsp.musicFinished()) {
    exit();
  }
}

void exit() {
  nsp.close();
  super.exit();
}
