import ddf.minim.*;
import ddf.minim.ugens.*;
import javax.sound.sampled.*;

CraftMusic cm;
CraftUgen cu;

Minim minim;
AudioOutput out;

int mixerNo = 2;

void setup() {
  size(256, 256);
  background(0);
  minim = new Minim(this);
  Mixer.Info[] mixerInfo = AudioSystem.getMixerInfo();
  for(int i = 0; i < mixerInfo.length; i++) println("Mixer "+i+": "+mixerInfo[i].getName());
  Mixer mixer = AudioSystem.getMixer(mixerInfo[mixerNo]);
  minim.setOutputMixer(mixer);
  out = minim.getLineOut(Minim.MONO, 2048);
  cm = new CraftMusic(m_trackdata, m_instrdata, m_instrtab_pre, m_instrtab, m_tracktab, m_song);
  cm.mutes[0] = false;
  cm.mutes[1] = false;
  cm.mutes[2] = false;
  cm.mutes[3] = false;
  cu = new CraftUgen(cm);
  cu.patch(out);
}
void draw() {
  background(0);
  text(hex(cm.c_vrate[0],2),0,16);
  text(hex(cm.c_vrate[1],2),0,32);
  text(hex(cm.c_vrate[2],2),0,48);
}
