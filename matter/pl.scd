

(
s.options.device_("Aggregate Device");
s.options.numWireBufs = 1024*4;
s.options.numOutputBusChannels=4;
s.options.numInputBusChannels=2;
TempoClock.default.tempo_(1);
s.options.memSize = 8192*128*2;
s.options.blockSize = 64*4;
s.options.maxNodes = 1024 * 16;
s.options.sampleRate= 44100;s.boot;
s.recHeaderFormat="aiff";
//s.recSampleFormat ="int16";
s.recChannels = 4;
)

(
{
var w, x, y, z, p,ch1,ch2,ch3,ch4;

ch1=FreeVerb.ar(SoundIn.ar(0),0.1,0.2);
ch2=FreeVerb.ar(SoundIn.ar(1),0.2,0.2);
ch3=FreeVerb.ar(SoundIn.ar(0),0.25,0.2);
ch4=FreeVerb.ar(SoundIn.ar(1),0.3,0.2);

w=1*(ch1+ch2+ch3+ch4)*2.sqrt;
x=1*(ch1-ch2-ch3+ch4)*2.sqrt;
y=1*(ch1-ch2+ch3-ch4)*2.sqrt;
z=1*(ch1+ch2-ch3-ch4)*2.sqrt;

x=x; y=y;

// B-format decode to stereo with speakers at different distances
//Out.ar(0,DecodeB2.ar(2,w, x, y,0.5).fold2(1));
//Out.ar(0,DecodeB2.ar(2,w, x, y,0.5).fold2(1));

Out.ar(0,x.fold2(1));
Out.ar(1,y.fold2(1));
Out.ar(2,z.fold2(1));

}.play;
//s.record(numChannels:2,duration:((9*60)+10));
)
