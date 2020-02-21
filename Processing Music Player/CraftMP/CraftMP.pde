CraftMusic cm;
NativeSoundPlayer nsp;

int sampleRate = 44100;
boolean recordOutput = false;
float outSpeedMult = 1; //pow(pow(2,1/12f),0);
int isolateChannel = -1;
String nameInsert = "-debug";
boolean enableSwing = false;

void setup() {
  size(256, 192);
  background(0);
  cm = new CraftMusic(m_trackdata, m_instrdata, m_instrtab_pre, m_instrtab, m_tracktab, m_song, m_freq);
  cm.enableSwing(enableSwing);
  String chName = "all";
  if(isolateChannel >= 0 && isolateChannel <= 3) {
    chName = "ch"+isolateChannel;
    for(int i = 0; i <= 3; i++) cm.mutes[i] = (i != isolateChannel);
  }
  nsp = new NativeSoundPlayer(cm, sampleRate, recordOutput ? new File(sketchPath("soundtrack" + nameInsert + "-" + chName + ".wav")) : null, outSpeedMult);
  nsp.open();
}
void draw() {
  background(0);
  text("Note0 " + hex(cm.c_inote[0], 4), 0, 16);
  text("Note1 " + hex(cm.c_inote[1], 4), 0, 32);
  text("Note2 " + hex(cm.c_inote[2], 4), 0, 48);
  if(nsp.musicFinished()) {
    exit();
  }
}

void exit() {
  nsp.close();
  super.exit();
}
