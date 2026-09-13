  ///Quarks.install("MathLib");

//s.record(numChannels:6);
(
(
s.options.numWireBufs = 1024*16;
s.options.numOutputBusChannels=5;
s.options.numInputBusChannels=0;
s.options.memSize = 8192*256;
s.options.blockSize = 64;
s.options.maxNodes = 8192*2;
//s.options.sampleRate=44100;
Buffer.freeAll;
Window.closeAll;
//s.makeGui(w);
s.meter;
s.freqscope;
s.scope;
);
s.waitForBoot{
Tdef(\drone, {
//~c1 = Buffer.readChannel(s,,channels:0 );
//~c2 = Buffer.readChannel(s,,channels:1 );
//////point arrays
(
{
var az1=0,el1=0,az2=0,el2=0,angle=0;
var silver_r=(1+2.sqrt), g=((1+5.sqrt)/2), azimuth, elevation;

~azimuthr=[]; ~elevationr=[];

32.do{
    azimuth = 32.collect{
        az1 = (az1 + (2pi-(2pi/g))).wrap(pi.neg,pi);
        el1 = (el1 + (pi-(pi/g))).wrap((pi/2).neg,(pi/2));
        (az1 + angle).wrap(pi.neg,pi)
    };

    elevation = 32.collect{
        az2 = (az2 + (2pi-(2pi/g))).wrap(pi.neg,pi);
        el2 = (el2 + (pi-(pi/g))).wrap((pi/2).neg,(pi/2));
        (el2 + angle).wrap((pi/2).neg,(pi/2))
    };

    angle = (angle + (2pi-(2pi/g))).wrap(pi.neg,pi);

    ~azimuthr = ~azimuthr ++ azimuth;
    ~elevationr = ~elevationr ++ elevation;

    az1=0; el1=0;
    az2=0; el2=0;
};
}.value;
);		0.1.wait;

///////tetrahedron
(
~azimuth=[45.degrad,135.neg.degrad,45.neg.degrad,135.degrad];
~elevation=[35.264390.neg.degrad,35.264390.neg.degrad,35.264390.degrad,35.264390.degrad];
//~elevation=[0,0,0,0];
);


0.1.wait;

///////////inputs
~rx=0;~ry=0;~rz=0;~gain=1;~fundament=0;~resonance=0;~harmonic=1;~fold=0;~room=0;~azs=0;~els=0;
~azr=1;~elr=1;
~temperament=16256;
~lagtime=1/256;
~frames=512.reciprocal;
~x=0;~y=0;~z=0;
~ffreq=64;
~window=110;
~dur=~frames*~window;
~spinbind=0.5pi;

//angle compensatiom
~s=(1+2.sqrt);
~g=((1+5.sqrt)/2);

//////////rotation
(
{var sph,az,el,bamk=2.pow(3),sl;n=~azimuthr.size.rand;
			//	n=0;
Routine({loop{
n=0;~az=[];~el=[];
bamk.do{
az=~azimuthr.[n];
el=~elevationr.[n];
n=n+1;
sph=Spherical(1,az,el);
//sph=sph.rotateXY(~z.lag2(~lagtime)).asSpherical;///static z interferance
sph=sph.rotateYZ(~x.lag2(~lagtime)).rotateXZ(~y.lag2(~lagtime)).rotateXY(~z.lag2(~lagtime));//orchestral
~az=~az++[sph.theta];
~el=~el++[sph.phi];
~az=~az.clip2(~spinbind);
~el=~el.clip2(~spinbind/2);
};
(~frames).wait;
};
}).play;
}.defer
);

(
{var rot;
Routine({loop{
//rot=Spherical(~dur,~azr,~elr);
~x=(~x+(~azr*((2pi-(2pi/~g))*(~frames/64)))).wrap(0,2pi);
~y=(~y+(~azr*((2pi-(2pi/~g))*(~frames/64)))).wrap(0,2pi);
~z=(~z+(~elr*((2pi-(2pi/~g))*(~frames/64)))).wrap(0,2pi);
(~frames).wait;
};
}).play;
}.defer
);
0.1.wait;

////////////osc table
~wavec=16256;
(
~n=1.neg;~array=~wavec.collect{~n=~n+1;2.pow(~n/~wavec)};
~n=(0-(2pi/~wavec)); ~ph=~wavec.collect{~n=~n+(2pi/~wavec);};
~bufferSize = 2048*8;~signalSize = 1024*8;
~wt= Buffer.alloc(s,~bufferSize);
{
var signal,wt;
signal=Signal.sineFill(~signalSize,~array,~ph); wt = signal.asWavetable; ~wt.loadCollection(wt);
//signal.plot;
}.value
);
0.5.wait;

////wave table
		~wavecc=56;
(
~nc=1.neg;~arrayc=~wavecc.collect{~nc=~nc+1;2.pow(~nc/~wavecc)};
~nc=(0-(2pi/~wavecc)); ~phc=~wavecc.collect{~nc=~nc+(2pi/~wavecc);};
~bufferSizec = 2048*1;~signalSizec = 1024*1;
~wtc= Buffer.alloc(s,~bufferSizec);
{
var signal,wt;
signal=Signal.sineFill(~signalSizec,~arrayc,~phc); wt = signal.asWavetable; ~wtc.loadCollection(wt);
//signal.plot;
}.value
);


(//scales
(~note=7;
~scale1=[0,5,7,12,17,19,24];
({var nn=1.neg;
~scale2=~note.collect{nn=nn+1;Scale.dorian.performDegreeToKey(nn,12)}}.value);
({var nn=1.neg;
~scale3=~note.collect{nn=nn+1;Scale.ionian.performDegreeToKey(nn,12)}}.value);
({var nn=1.neg;
~scale4=~note.collect{nn=nn+1;Scale.phrygian.performDegreeToKey(nn,12)}}.value);
({
var nn=1.neg,scale1,scale2;
~scale5=~note.collect{nn=nn+1;Scale.minorPentatonic.performDegreeToKey(nn,12)};
nn=1.neg;
~scale6=~note.collect{nn=nn+1;Scale.majorPentatonic.performDegreeToKey(nn,12)};
}.value));
~scale=[~scale1,~scale2,~scale3,~scale4,~scale5,~scale6]);

////seq
~fuselim=(16256*9).neg;
~comp=3;
~distortion=0.1;
~noise=0.0001;
~complevel=1024;
///////////////////feed
0.1.wait;
(
SynthDef.new(\synth,{

arg gain=0,fundamental=0,resonanse=0,harm=1,room=0,drive=0,mag=0,dist=1,voice=0.1,
tone=1,scselect=0,key=0,v=1,l1=1,l2=1,az=#[0,0,0,0],el=#[0,0,0,0];
var level,res,revroom,overdrive,x,y,z,tx,ty,tz,trange,busarray2,pitchx,pitchy,pitch;
var freqx,freqy,freqz,ampx,ampy,ampz,tonex,toney,tonez,tune=~ffreq*(9/8),phasex,phasey,phasez,snt;
var c1,c2,c3,sigx,sigy,sigz,azn,eln,cx,cy,cz,g1,g2,g3,g4,thresholdk,note;
var n=0,polytope=2,busarray1,harmonic,fund,mix,a,b,cc,immersion,busarray,gate,threshold;
var xp,yp,zp,kx,ky,kz,vx,vy,vz,formants,c12,c22,env,paner;

///inputs
level=2.pow(gain.lag2(~lagtime)/16256);
///level=gain;
c=2.pow(fundamental.lag2(~lagtime)/16256);
res=2.pow(resonanse.lag2(~lagtime)/16256);
revroom=2.pow(room.lag2(~lagtime)/16256);
overdrive=2.pow(drive.lag2(~lagtime)/16256);

harmonic=harm;
trange=mag.lag2(~lagtime);
level=level;

note=2.pow(key.lag2(~lagtime)/12);

env=EnvGen.ar(Env.perc(0.01,2,0.25),gate:Trig1.kr(Changed.kr(key), 0.01));
level=level*(env+1);

///pitch
fund=c*tune;
pitch=exp(Complex(0,1)*tone);
pitchx=2.pow(Select.kr((pitch.real*~note).abs,Select.kr(scselect,~scale))/12);
pitchy=2.pow(Select.kr((pitch.imag*~note).abs,Select.kr(scselect,~scale))/12);

n=0;
polytope.do{

azn=az.[n].lag2(~lagtime);
eln=el.[n].lag2(~lagtime);

///spat
//verb
xp = ((harmonic*cos(eln)*cos(azn))+(cos(harmonic*(eln))*cos(harmonic*(azn))))/harmonic.sqrt;
yp = ((harmonic*cos(eln)*sin(azn))+(cos(harmonic*(eln))*sin(harmonic*(azn))))/harmonic.sqrt;
zp = ((harmonic*sin(eln))+(sin(harmonic*(eln))))/harmonic.sqrt;
///tone
kx=((Complex(cos(azn*harmonic),cos(azn*harmonic)).rho/(1.sqrt))*(Complex(cos(eln),cos(eln)).rho/(1.sqrt)));
ky=((Complex(sin(azn*harmonic),sin(azn*harmonic)).rho/(1.sqrt))*(Complex(cos(eln),cos(eln)).rho/(1.sqrt)));
kz=(Complex(sin(eln*harmonic),sin(eln*harmonic))).rho/(1.sqrt);
//pan
x =(cos(eln)*cos(azn));
y =(cos(eln)*sin(azn));
z =(sin(eln));

//////perspective
immersion = (level/dist) / ((level/dist) + z + ((level/dist)/2));
////temperament
tx = (trange*kx);
ty = (trange*ky);
tz = (trange*kz);
tonex=2.pow(tx.round(1)/~temperament);
toney=2.pow(ty.round(1)/~temperament);
tonez=2.pow(tz.round(1)/~temperament);

////osc data
freqx=(fund*pitchx)*tonex*note;
freqy=(fund*pitchy)*toney*note;
freqz=fund*tonez*note;
ampx=c.reciprocal*tonex.reciprocal*level*note.reciprocal;
ampy=c.reciprocal*toney.reciprocal*level*note.reciprocal;
ampz=c.reciprocal*tonez.reciprocal*level*note.reciprocal;
//phase set
//phasex=(Complex(1,x).theta*2);
//phasey=(Complex(1,y).theta*2);
//phasez=(Complex(1,z).theta*2);
//phasex=atan2(x,y);
//phasey=atan2(y,z);
//phasez=atan2(z,x);
phasex=(x*2pi);
phasey=(y*2pi);
phasez=(z*2pi);


/////////osc
c1=BPF.ar((Osc.ar(~wt.bufnum,freqx,phase:phasex,mul:~complevel).abs*
SinOsc.ar(freqx,phase:phasex)),freqx,res,ampx*x.sign*1);
c2=BPF.ar((Osc.ar(~wt.bufnum,freqy,phase:phasey,mul:~complevel).abs*
SinOsc.ar(freqy,phase:phasey)),freqy,res,ampy*y.sign*1);
c3=BPF.ar((Osc.ar(~wt.bufnum,freqz,phase:phasez,mul:~complevel).abs*
SinOsc.ar(freqz,phase:phasez)),freqz,res,ampz*z.sign);

c12=BPF.ar((Osc.ar(~wt.bufnum,(fund)*2,phase:phasex,mul:~complevel).abs*
SinOsc.ar((fund)*2,phase:phasex)),(fund)*2,res,ampx*x.sign/2)*l1;
c22=BPF.ar((Osc.ar(~wt.bufnum,(fund)/2,phase:phasey,mul:~complevel).abs*
SinOsc.ar((fund)/2,phase:phasey)),(fund)/2,res,ampy*y.sign*2)*l2;

c1=c1+c12; c2=c2+c22;
///distortion
mix=overdrive.linlin(1,2.pow(~fuselim/16256),2.pow(~fuselim/16256),1);

c1=c1.lag2(~signalSize.reciprocal)*
(LPF.ar(Saw.ar(tune,(ampx)),tune*64*mix).fold2(mix*~distortion)+((ampx)));
c2=c2.lag2(~signalSize.reciprocal)*
(LPF.ar(Saw.ar(tune,(ampy)),tune*64*mix).fold2(mix*~distortion)+((ampy)));
c3=c3.lag2(~signalSize.reciprocal)*
(LPF.ar(Saw.ar(tune,(ampz)),tune*64*mix).fold2(mix*~distortion)+((ampz)));

///rev
sigx=FreeVerb.ar((c1).fold2(overdrive*~comp),xp.lag2(0.1).fold2(1).abs,revroom);
sigy=FreeVerb.ar((c2).fold2(overdrive*~comp),yp.lag2(0.1).fold2(1).abs,revroom);
sigz=FreeVerb.ar((c3).fold2(overdrive*~comp),zp.lag2(0.1).fold2(1).abs,revroom);

//vbap panner
/*(
g1=((cos(eln)*cos(azn)*cos(~azimuth.[0])*cos(~azimuth.[0]))
+
(cos(eln)*sin(azn)* cos(~elevation.[0])*sin(~azimuth.[0]))
+
(sin(eln)*sin(~elevation.[0])));

g2=((cos(eln)*cos(azn)*cos(~elevation.[1])*cos(~azimuth.[1]))
+
(cos(eln)*sin(azn)*cos(~elevation.[1])*sin(~azimuth.[1]))
+
(sin(eln)*sin(~elevation.[1])));

g3=((cos(eln)*cos(azn)*cos(~elevation.[2])*cos(~azimuth.[2]))
+
(cos(eln)*sin(azn)*cos(~elevation.[2])*sin(~azimuth.[2]))
+
(sin(eln)*sin(~elevation.[2])));

g4=((cos(eln)*cos(azn)*cos(~elevation.[3])*cos(~azimuth.[3]))
+
(cos(eln)*sin(azn)*cos(~elevation.[3])*sin(~azimuth.[3]))
+
(sin(eln)*sin(~elevation.[3])));
);*/

///sig
a=HPF.ar((LeakDC.ar((sigx)*((sigz).fold2(overdrive*~distortion)+(ampz)))),64);
b=HPF.ar((LeakDC.ar((sigy)*((sigz).fold2(overdrive*~distortion)+(ampz)))),64);
cc=HPF.ar((LeakDC.ar((sigz)*((sigz).fold2(overdrive*~distortion)+(ampz)))),64);

threshold=(((343/0.15)/tune).reciprocal.ampdb/2.sqrt).dbamp;
a=Compander.ar(sigx,sigx,threshold,1.2,1/3,0.03,0.15)+BrownNoise.ar(0.000001);
b=Compander.ar(sigy,sigy,threshold,1.2,1/3,0.03,0.15)+BrownNoise.ar(0.000001);
cc=Compander.ar(sigz,sigz,threshold,1.2,1/3,0.03,0.15)+BrownNoise.ar(0.000001);

//formants
//aeiou	//freq,bandwidth,amp
/*formants=[
[[800,0.8,0.dbamp],[1150,0.9,4.neg.dbamp],[2800,1.2,20.neg.dbamp]],
[[400,0.6,0.dbamp],[1600,0.8,24.neg.dbamp],[2700,1.2,30.neg.dbamp]],
[[350,0.5,0.dbamp],[1700,1,20.neg.dbamp],[2700,1.2,30.neg.dbamp]],
[[450,0.7,0.dbamp],[800,0.8,9.neg.dbamp],[2830,1,16.neg.dbamp]],
[[325,0.5,0.dbamp],[700,0.6,12.neg.dbamp],[2530,1.7,30.neg.dbamp]],
];

vx=BPF.ar(a,Select.kr(v,formants).[0].[0],Select.kr(v,formants).[0].[1]*voice,Select.kr(v,formants).[0].[2])*(level/voice.sqrt);
vy=BPF.ar(b,Select.kr(v,formants).[1].[0],Select.kr(v,formants).[1].[1]*voice,Select.kr(v,formants).[1].[2])*(level/voice.sqrt);
vz=BPF.ar(cc,Select.kr(v,formants).[2].[0],Select.kr(v,formants).[2].[1]*voice,Select.kr(v,formants).[2].[2])*(level/voice.sqrt);

a=vx;
b=vy;
cc=vz;*/

///wavefield out wavefield presenst in record, audio format headphones or mono
//use z for mono out
//busarray1=[0,2,4,6,8,10,12,14];
//busarray2=[1,3,5,7,9,11,13,15];
//Out.ar(2,a.softclip(3));
//Out.ar(3,b.softclip(3));
//Out.ar(4,cc.softclip(3));

//vbap out
/*(
Out.ar(0,a.softclip(3)*g1);
Out.ar(1,a.softclip(3)*g2);
Out.ar(2,a.softclip(3)*g3);
Out.ar(3,a.softclip(3)*g4);
Out.ar(0,b.softclip(3)*g1);
Out.ar(1,b.softclip(3)*g2);
Out.ar(2,b.softclip(3)*g3);
Out.ar(3,b.softclip(3)*g4);
Out.ar(0,cc.softclip(3)*g1);
Out.ar(1,cc.softclip(3)*g2);
Out.ar(2,cc.softclip(3)*g3);
Out.ar(3,cc.softclip(3)*g4);
)*/

//pan stereo out, wavefield mixed, if recorded on stereo stereo ouput acoustics present, if mono out record, audio format stereo speakers
//field
paner=Cartesian(x,y,z);
Out.ar(0,Pan2.ar(a.softclip(3),(paner.theta.linlin(pi.neg,pi,1.neg,1).wrap(0,1))));
Out.ar(0,Pan2.ar(b.softclip(3),(paner.theta.linlin(pi.neg,pi,1.neg,1).wrap(0,1.neg))));
Out.ar(0,Pan2.ar(cc.softclip(3),(paner.phi.linlin(0.5pi.neg,0.5pi,1.neg,1))));

//quad out
//Out.ar(0,Pan4.ar(a.softclip(3),(x.wrap2(1))*immersion,(y.wrap2(1))*immersion));
//Out.ar(0,Pan4.ar(b.softclip(3),(x.wrap2(1))*immersion,(y.wrap2(1))*immersion));

//mono out
//Out.ar(0,a.softclip(2));
//Out.ar(0,b.softclip(2));
//Out.ar(0,a.softclip(2));
//Out.ar(0,b.softclip(2));
//Out.ar(0,cc.softclip(2));

n=n+1;
};
}).add;
);

4.wait;

///data
(
~time=1;
~clock=TempoClock.default.tempo_(2);
~attack=0.000001/~time;
);
(
~setnote=0;
~fundamental=0;
~tone=0;
~gain=1;
~resonanse=1;
~harm=1;
~drive=0;
~room=0;
~mag=1;
~tone=1;
~scaleselect=0;
~curve=1.neg;
~dist=1;
~v=1;
~voice=0.1;
~l1=0;
~l2=1;
);

///melody
~sn=0;

//feed
(
{
Routine({loop{
//~synth.set(\az,[~az.[0],~az.[1],~az.[2],~az.[3]],\el,[~el.[0],~el.[1],~el.[2],~el.[3]]);
~azset=~az;
~elset=~el;
(~frames).wait
}
}).play;
}.defer
);

///patterns
(
(~pattern1 = Pdef(\1,
Pmono( \synth,
\dur,Pfunc{~frames*2},
\gain,Pfunc{~gain},
\fundamental,Pfunc{~fundamental},
\tone,Pfunc{~tone},
\resonanse,	Pfunc{~resonanse},
\harm,Pfunc{~harm},
\drive,Pfunc{~drive},
\room,Pfunc{~room},
\mag,Pfunc{~mag},
\az,Pfunc{Ref([~azset.[0],~azset.[1],~azset.[2],~azset.[3]])},
\el,Pfunc{Ref([~elset.[0],~elset.[1],~elset.[2],~elset.[3]])},
\scselect,Pfunc{~scaleselect},
//\key,Prand([0, 4, 9, 2, 7],inf),
\key,Pfunc{~sn},
\dist,Pfunc{~dist},
\voice,Pfunc{~voice},
\l1,Pfunc{~l1},
\l2,Pfunc{~l2},
\v,Pseq([0,1,2,3,4],inf),
//\v,Pseq([0],inf)
)));

/*(~pattern2 = Pdef(\2,
Pmono( \synth,
\dur,Pfunc{~frames},
\gain,Pfunc{~gain},
\fundamental,Pfunc{~fundamental},
\tone,Pfunc{~tone},
\resonanse,	Pfunc{~resonanse},
\harm,Pfunc{~harm},
\drive,Pfunc{~drive},
\room,Pfunc{~room},
\mag,Pfunc{~mag},
\az,Pfunc{Ref([~azset.[0],~azset.[1],~azset.[2],~azset.[3]])},
\el,Pfunc{Ref([~elset.[0],~elset.[1],~elset.[2],~elset.[3]])},
\scselect,Pfunc{~scaleselect},
//\key,Prand([0, 4, 9, 2, 7],inf),
\key,Pfunc{~sn},
\dist,Pfunc{~dist},
\voice,Pfunc{~voice},
\v,Pseq([0,1,2,3,4],inf),
\l1,Pfunc{~l1},
\l2,Pfunc{~l2},
//\v,Pseq([0],inf)
)))*/
);
(
~pattern1.play;
//~pattern2.play;
);
/*(
~pattern1.stop;
~pattern2.s
top;

		)*/

/*(
s.record(numChannels:2);
{Out.ar(0,PlayBuf.ar(1, ~c1.bufnum, BufRateScale.kr(~c1), loop: 0,doneAction:0))}.play;
{Out.ar(1,PlayBuf.ar(1, ~c2.bufnum, BufRateScale.kr(~c2), loop: 0,doneAction:0))}.play;
)*/
		0.1.wait;
		/////////midi
(
MIDIClient.init;
MIDIIn.connectAll;
(
MIDIdef.cc(\midi_pot1,{ |val, num, chan, src|
var gain;
gain=val.linlin(0,127,(16256*4).neg,16256*2).round(1);
//gain=val.linlin(0,127,0,1);
gain.postln;
~gain=gain;
},1);
);
(
MIDIdef.cc(\midi_pot2,{ |val, num, chan, src|
var fund;
fund=val.linlin(0,127,16256*3.neg,16256*2).round(1);
fund.postln;
~fundamental=fund;
},2);
);
(
MIDIdef.cc(\midi_pot3,{ |val, num, chan, src|
var res;
res=val.linlin(0,127,(16256*8).neg,16256*4).round(1);
res.postln;
~resonanse=res;
},3);
);
(
MIDIdef.cc(\midi_pot4,{ |val, num, chan, src|
var drive;
drive=val.linlin(0,127,0,~fuselim).round(1);
drive.postln;
~drive=drive;
},4);
);
(
MIDIdef.cc(\midi_pot5,{ |val, num, chan, src|
var harm;
harm=val.linlin(0,127,1,31).round(1).postln;
harm.postln;
~harm=harm;
},5);
);
(
MIDIdef.cc(\midi_pot6,{ |val, num, chan, src|
var room;
room=val.linlin(0,127,(16256*12).neg,0).round(1);
room.postln;
~room=room;
},6);
);
(
MIDIdef.cc(\midi_pot7,{ |val, num, chan, src|
var mag;
mag=val.linlin(0,127,0,~temperament/2).round(1);
mag.postln;
~mag=mag;
},7);
);
(
MIDIdef.cc(\midi_pot8,{ |val, num, chan, src|
var r;
r=val.linlin(0,127,0.5pi.neg,0.5pi);
~azr=r;
~elr=r/2;
r.postln;
},8);
);
(
MIDIdef.cc(\midi_pot9,{ |val, num, chan, src|
var tone;
tone=val.linlin(0,127,pi.neg,pi);
tone.postln;
~tone=tone;
},9);
);
(
MIDIdef.cc(\midi_pot10,{ |val, num, chan, src|
var sc;
sc=val.linlin(0,127,0,5).round(1);
sc.postln;
~scaleselect=sc;g;
},10);
);
(
MIDIdef.cc(\midi_pot11,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,0.01pi,pi);
note.postln;
~spinbind=note;
},11);
);
(
MIDIdef.cc(\midi_pot12,{ |val, num, chan, src|
var l2;
l2=val.linlin(0,127,0,1);
l2.postln;
~l2=l2;
},12);
);
(
MIDIdef.cc(\midi_pot13,{ |val, num, chan, src|
var sc;
sc=val.linlin(0,127,0.0001,1);
sc.postln;
~voice=sc;
},13);
);
(
MIDIdef.cc(\midi_pot14,{ |val, num, chan, src|
var l1;
l1=val.linlin(0,127,0,1);
l1.postln;
~l1=l1;
},14);
);
(
MIDIdef.cc(\midi_pot15,{ |val, num, chan, src|
var dist;
dist=val.linlin(0,127,0.01,10);
dist.postln;
~dist=dist;
},15);
);
(
MIDIdef.cc(\midi_pot155,{ |val, num, chan, src|
var l2;
l2=val.linlin(0,127,0,1);
l2.postln;
~l2=l2;
},16);
);
(
MIDIdef.cc(\midi_pot16,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,0,0).round(0);
note.postln;
~sn=note;
},17);
);
(
MIDIdef.cc(\midi_pot17,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,2,2).round(2);
note.postln;
~sn=note;
},18);
);
(
MIDIdef.cc(\midi_pot18,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,3,3).round(3);
note.postln;
~sn=note;
},19);
);
(
MIDIdef.cc(\midi_pot19,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,5,5).round(5);
note.postln;
~sn=note;
},20);
);
(
MIDIdef.cc(\midi_pot20,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,7,7).round(7);
note.postln;
~sn=note;
},21);
);
(
MIDIdef.cc(\midi_pot21,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,9,9).round(9);
note.postln;
~sn=note;
},22);
);
(
MIDIdef.cc(\midi_pot22,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,10,10).round(10);
note.postln;
~sn=note;
},23);
);
(
MIDIdef.cc(\midi_pot23,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,7,7).round(7);
note.postln;
~sn=note;
},24);
);
(
MIDIdef.cc(\midi_pot24,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,8,8).round(8);
note.postln;
~sn=note;
},25);
);
(
MIDIdef.cc(\midi_slider1,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,9,9).round(9);
note.postln;
~sn=note;
},26);
);
(
MIDIdef.cc(\midi_slider2,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,10,10).round(10);
note.postln;
~sn=note;
},27);
);
(
MIDIdef.cc(\midi_slider3,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,12,12).round(12);
note.postln;
~sn=note;
},28);
);
(
MIDIdef.cc(\midi_slider4,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,14,14).round(14);
note.postln;
~sn=note;
},29);
);
(
MIDIdef.cc(\midi_slider5,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,15,15).round(15);
note.postln;
~sn=note;
},30);
);
(
MIDIdef.cc(\midi_slider6,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,17,17).round(17);
note.postln;
~sn=note;
},31);
);
(
MIDIdef.cc(\midi_slider7,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,19,19).round(19);
note.postln;
~sn=note;
},32);
);
(
MIDIdef.cc(\midi_slider8,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,21,21).round(21);
note.postln;
~sn=note;
},33);
);
(
MIDIdef.cc(\midi_slider9,{ |val, num, chan, src|
var note;
note=val.linlin(0,127,22,22).round(22);
note.postln;
~sn=note;
},34);
);
);
////////////////////////gui
	1.wait;
(
{
var size=550,sk=(size/12),w,rol=0,sz=0.5,wd=3.5,shift=1;

w = Window("tws", Rect(50, 50, size+800, size)).front;
~vw1 = UserView(w, Rect(0,0,size+800,size)).background_(Color.black);
~logView1 = ListView( ~vw1, Rect(0, 0, size/4, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 18)).items_([]);

~logItems1 = List.new;
~log1 = { |msg| {~logItems1.add(msg); if(~logItems1.size > 200) { ~logItems1.removeAt(0);  };
~logView1.items_(~logItems1.asArray); ~logView1.value_(~logItems1.size - 1); }.defer;};


~vallogView1 = ListView( ~vw1, Rect(size, 0, 50, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 10)).items_([]);
~vallogItems1 = List.new;
~vallog1 = { |msg| {~vallogItems1.add(msg); if(~vallogItems1.size > 200) { ~vallogItems1.removeAt(0);  };
~vallogView1.items_(~vallogItems1.asArray); ~vallogView1.value_(~vallogItems1.size - 1); }.defer;};

~vallogView2 = ListView( ~vw1, Rect(size+50, 0, 50, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 10)).items_([]);
~vallogItems2 = List.new;
~vallog2 = { |msg| {~vallogItems2.add(msg); if(~vallogItems2.size > 200) { ~vallogItems2.removeAt(0);  };
~vallogView2.items_(~vallogItems2.asArray); ~vallogView2.value_(~vallogItems2.size - 1); }.defer;};

~vallogView3 = ListView( ~vw1, Rect(size+100, 0, 50, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 10)).items_([]);
~vallogItems3 = List.new;
~vallog3 = { |msg| {~vallogItems3.add(msg); if(~vallogItems3.size > 200) { ~vallogItems3.removeAt(0);  };
~vallogView3.items_(~vallogItems3.asArray); ~vallogView3.value_(~vallogItems3.size - 1); }.defer;};

~vallogView4 = ListView( ~vw1, Rect(size+150, 0, 50, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 10)).items_([]);
~vallogItems4 = List.new;
~vallog4 = { |msg| {~vallogItems4.add(msg); if(~vallogItems4.size > 200) { ~vallogItems4.removeAt(0);  };
~vallogView4.items_(~vallogItems4.asArray); ~vallogView4.value_(~vallogItems4.size - 1); }.defer;};

~vallogView5 = ListView( ~vw1, Rect(size+200, 0, 50, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 10)).items_([]);
~vallogItems5 = List.new;
~vallog5 = { |msg| {~vallogItems5.add(msg); if(~vallogItems5.size > 200) { ~vallogItems5.removeAt(0);  };
~vallogView5.items_(~vallogItems5.asArray); ~vallogView5.value_(~vallogItems5.size - 1); }.defer;};

~vallogView6 = ListView( ~vw1, Rect(size+250, 0, 50, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 10)).items_([]);
~vallogItems6 = List.new;
~vallog6 = { |msg| {~vallogItems6.add(msg); if(~vallogItems6.size > 200) { ~vallogItems6.removeAt(0);  };
~vallogView6.items_(~vallogItems6.asArray); ~vallogView6.value_(~vallogItems6.size - 1); }.defer;};

~vallogView7 = ListView( ~vw1, Rect(size+300, 0, 50, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 10)).items_([]);
~vallogItems7 = List.new;
~vallog7 = { |msg| {~vallogItems7.add(msg); if(~vallogItems7.size > 200) { ~vallogItems7.removeAt(0);  };
~vallogView7.items_(~vallogItems7.asArray); ~vallogView7.value_(~vallogItems7.size - 1); }.defer;};

~vallogView8 = ListView( ~vw1, Rect(size+350, 0, 50, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 10)).items_([]);
~vallogItems8 = List.new;
~vallog8 = { |msg| {~vallogItems8.add(msg); if(~vallogItems8.size > 200) { ~vallogItems8.removeAt(0);  };
~vallogView8.items_(~vallogItems8.asArray); ~vallogView8.value_(~vallogItems8.size - 1); }.defer;};

~vallogView9 = ListView( ~vw1, Rect(size+400, 0, 50, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 10)).items_([]);
~vallogItems9 = List.new;
~vallog9 = { |msg| {~vallogItems9.add(msg); if(~vallogItems9.size > 200) { ~vallogItems9.removeAt(0);  };
~vallogView9.items_(~vallogItems9.asArray); ~vallogView9.value_(~vallogItems9.size - 1); }.defer;};

~vallogView10 = ListView( ~vw1, Rect(size+450, 0, 50, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 10)).items_([]);
~vallogItems10 = List.new;
~vallog10 = { |msg| {~vallogItems10.add(msg); if(~vallogItems10.size > 200) { ~vallogItems10.removeAt(0);  };
~vallogView10.items_(~vallogItems10.asArray); ~vallogView10.value_(~vallogItems10.size - 1); }.defer;};

~vallogView11 = ListView( ~vw1, Rect(size+500, 0, 50, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 10)).items_([]);
~vallogItems11 = List.new;
~vallog11 = { |msg| {~vallogItems11.add(msg); if(~vallogItems11.size > 200) { ~vallogItems11.removeAt(0);  };
~vallogView11.items_(~vallogItems11.asArray); ~vallogView11.value_(~vallogItems11.size - 1); }.defer;};

~vallogView12 = ListView( ~vw1, Rect(size+550, 0, 50, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 10)).items_([]);
~vallogItems12 = List.new;
~vallog12 = { |msg| {~vallogItems12.add(msg); if(~vallogItems12.size > 200) { ~vallogItems12.removeAt(0);  };
~vallogView12.items_(~vallogItems12.asArray); ~vallogView12.value_(~vallogItems12.size - 1); }.defer;};

~vallogView13 = ListView( ~vw1, Rect(size+600, 0, 50, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 10)).items_([]);
~vallogItems13 = List.new;
~vallog13 = { |msg| {~vallogItems13.add(msg); if(~vallogItems13.size > 200) { ~vallogItems13.removeAt(0);  };
~vallogView13.items_(~vallogItems13.asArray); ~vallogView13.value_(~vallogItems13.size - 1); }.defer;};

~vallogView14 = ListView( ~vw1, Rect(size+650, 0, 50, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 10)).items_([]);
~vallogItems14 = List.new;
~vallog14 = { |msg| {~vallogItems14.add(msg); if(~vallogItems14.size > 200) { ~vallogItems14.removeAt(0);  };
~vallogView14.items_(~vallogItems14.asArray); ~vallogView14.value_(~vallogItems14.size - 1); }.defer;};

~vallogView15 = ListView( ~vw1, Rect(size+700, 0, 50, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 10)).items_([]);
~vallogItems15 = List.new;
~vallog15 = { |msg| {~vallogItems15.add(msg); if(~vallogItems15.size > 200) { ~vallogItems15.removeAt(0);  };
~vallogView15.items_(~vallogItems15.asArray); ~vallogView15.value_(~vallogItems15.size - 1); }.defer;};

~vallogView16 = ListView( ~vw1, Rect(size+750, 0, 50, size)).background_(Color.black)
.stringColor_(Color.white).font_(Font('Arial', 10)).items_([]);
~vallogItems16 = List.new;
~vallog16 = { |msg| {~vallogItems16.add(msg); if(~vallogItems16.size > 200) { ~vallogItems16.removeAt(0);  };
~vallogView16.items_(~vallogItems16.asArray); ~vallogView16.value_(~vallogItems16.size - 1); }.defer;};

~nam2=StaticText(~vw1,Rect(size,0,50,50)).string_("az1")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',10));
~nam3=StaticText(~vw1,Rect(size+50,0,50,50)).string_("el1")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',10));
~nam4=StaticText(~vw1,Rect(size+100,0,50,50)).string_("az2")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',10));
~nam5=StaticText(~vw1,Rect(size+150,0,50,50)).string_("el2")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',10));
~nam6=StaticText(~vw1,Rect(size+200,0,50,50)).string_("az3")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',10));
~nam7=StaticText(~vw1,Rect(size+250,0,50,50)).string_("el3")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',10));
~nam8=StaticText(~vw1,Rect(size+300,0,50,50)).string_("az4")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',10));
~nam9=StaticText(~vw1,Rect(size+350,0,50,50)).string_("el4")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',10));
~nam10=StaticText(~vw1,Rect(size+400,0,50,50)).string_("az5")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',10));
~nam11=StaticText(~vw1,Rect(size+450,0,50,50)).string_("el5")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',10));
~nam12=StaticText(~vw1,Rect(size+500,0,50,50)).string_("az6")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',10));
~nam13=StaticText(~vw1,Rect(size+550,0,50,50)).string_("el6")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',10));
~nam14=StaticText(~vw1,Rect(size+600,0,50,50)).string_("az7")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',10));
~nam15=StaticText(~vw1,Rect(size+650,0,50,50)).string_("el7")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',10));
~nam16=StaticText(~vw1,Rect(size+700,0,50,50)).string_("az8")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',10));
~nam17=StaticText(~vw1,Rect(size+750,0,50,50)).string_("el8")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',10));

({Routine({loop{
~vallog1.(~az.[0].asString);
~vallog2.(~el.[0].asString);
~vallog3.(~az.[1].asString);
~vallog4.(~el.[1].asString);
~vallog5.(~az.[2].asString);
~vallog6.(~el.[2].asString);
~vallog7.(~az.[3].asString);
~vallog8.(~el.[3].asString);
~vallog9.(~az.[4].asString);
~vallog10.(~el.[4].asString);
~vallog11.(~az.[5].asString);
~vallog12.(~el.[5].asString);
~vallog13.(~az.[6].asString);
~vallog14.(~el.[6].asString);
~vallog15.(~az.[7].asString);
~vallog16.(~el.[7].asString);
(0.25).wait}}).play;
}.defer);


~nam1=StaticText(~vw1,Rect(0,0,100,50)).string_("control inputs")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',16));

(
~sl1=Knob.new(~vw1, Rect.new(50,50,sk, sk)).background_(Color.black).action_({
arg obj;
var value;
value=obj.value.linlin(0,1,0.5pi.neg,0.5pi).postln;
//value=obj.value.linlin(0,1,1/4,4).round(1/16).postln;
~azr=value;
~elr=value/2;
//~clock.tempo_(value);
~log1.(value.asString);
});
~st1=StaticText(~vw1,Rect(50,50+sk,sk+20,sk)).string_("rot")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',16));
);

(
~sl2=Knob.new(~vw1, Rect.new(150,50,sk, sk)).background_(Color.black).action_({
arg obj;
var value;
value=obj.value.linlin(0,1,pi.neg,pi).postln;
//value=obj.value.linlin(0,1,0,~note).round(1).postln;
//~elr=value;
//~nset=value;
//~synth.set(\tone,value);
~tone=value;
~log1.(value.asString);
});
~st2=StaticText(~vw1,Rect(150,50+sk,sk+20,sk)).string_("tone")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',16));
);

(
~sl3=Knob.new(~vw1, Rect.new(250,50,sk, sk)).background_(Color.black).action_({
arg obj;
var value;
value=obj.value.linlin(0,1,(16256*4).neg,16256*2).round(1).postln;
//~synth.set(\gain,value);
~gain=value;
~log1.(value.asString);
});
~st3=StaticText(~vw1,Rect(250,50+sk,sk+20,sk)).string_("gain")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',16));
);

(
~sl4=Knob.new(~vw1, Rect.new(350,50,sk, sk)).background_(Color.black).action_({
arg obj;
var value;
value=obj.value.linlin(0,1,16256*3.neg,16256*2).round(1).postln;
//~synth.set(\fundamental,value);
~fundamental=value;
~log1.(value.asString);
});
~st4=StaticText(~vw1,Rect(350,50+sk,sk+20,sk)).string_("fund")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',16));
);

(
~sl5=Knob.new(~vw1, Rect.new(450,50,sk, sk)).background_(Color.black).action_({
arg obj;
var value;
value=obj.value.linlin(0,1,(16256*8).neg,16256*4).round(1).postln;
//~synth.set(\resonanse,value);
~resonanse=value;
~log1.(value.asString);
});

~st5=StaticText(~vw1,Rect(450,50+sk,sk+20,sk)).string_("resonance")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',16));
);

(
~sl6=Knob.new(~vw1, Rect.new(50,50+sk+50+25,sk, sk)).background_(Color.black).action_({
arg obj;
var value;
value=obj.value.linlin(0,1,1,16).round(1).postln;
//~synth.set(\harm,value);
~harm=value;
~log1.(value.asString);
});
~st6=StaticText(~vw1,Rect(50,(50+sk+50+25+sk),sk+20,sk)).string_("harmonic")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',16));
);
(

~sl7=Knob.new(~vw1, Rect.new(150,50+sk+50+25,sk, sk)).background_(Color.black).action_({
arg obj;
var value;
value=obj.value.linlin(0,1,0,~fuselim).round(1).postln;
//~synth.set(\drive,value);
~drive=value;
~log1.(value.asString);
});
~st7=StaticText(~vw1,Rect(150,(50+sk+50+25+sk),sk+20,sk)).string_("drive")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',16));
);

(
~sl8=Knob.new(~vw1, Rect.new(250,50+sk+50+25,sk, sk)).background_(Color.black).action_({
arg obj;
var value;
value=obj.value.linlin(0,1,0,1).postln;
//~synth.set(\perspective,value);
~l2=value;
~log1.(value.asString);
});
~st8=StaticText(~vw1,Rect(250,(50+sk+50+25+sk),sk+20,sk)).string_("strl2")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',16));
);

(
~sl9=Knob.new(~vw1, Rect.new(350,50+sk+50+25,sk, sk)).background_(Color.black).action_({
arg obj;
var value;
value=obj.value.linlin(0,1,(16256*12).neg,0).round(1).postln;
//~synth.set(\room,value);
~room=value;
~log1.(value.asString);
});
~st9=StaticText(~vw1,Rect(350,(50+sk+50+25+sk),sk+20,sk)).string_("room")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',16));
);

(
~sl10=Knob.new(~vw1, Rect.new(450,50+sk+50+25,sk, sk)).background_(Color.black).action_({
arg obj;
var value;
value=obj.value.linlin(0,1,0,~temperament/2).round(1).postln;
//~synth.set(\mag,value);
~mag=value;
~log1.(value.asString);
});
~st10=StaticText(~vw1,Rect(450,(50+sk+50+25+sk),sk+20,sk)).string_("magnitude")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',16));
);
(
~sl11=Knob.new(~vw1, Rect.new(50,(50+sk+50+sk+25+25+50),sk, sk)).background_(Color.black).action_({
arg obj;
var sc;
sc=obj.value.linlin(0,1,0,4).round(1);
sc.postln;
~scaleselect=sc;
~log1.(sc.asString);
});
~st11=StaticText(~vw1,Rect(50,(50+sk+50+sk+25+25+sk+50),sk+20,sk)).string_("scale")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',16));
);
/*(
~sl14=Knob.new(~vw1, Rect.new(350,(50+sk+50+sk+25+25+50),sk, sk)).background_(Color.black).action_({
arg obj;
var k;
k=obj.value.linexp(0,1,0.000001,1);
k.postln;
~attack=k/~time;
~log1.(k.asString);
});
~st14=StaticText(~vw1,Rect(350,(50+sk+50+sk+25+25+sk+50),sk+20,sk)).string_("attack")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',16));
)*/
(
~sl15=Knob.new(~vw1, Rect.new(450,(50+sk+50+sk+25+25+50),sk, sk)).background_(Color.black).action_({
arg obj;
var tempo;
	tempo=obj.value.linlin(0,1,0,1);
tempo.postln;
~l1=tempo;
~log1.(tempo.asString);
});
~st15=StaticText(~vw1,Rect(450,(50+sk+50+sk+25+25+sk+50),sk+20,sk)).string_("strl1")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',16));
);
(
~sl16=Knob.new(~vw1, Rect.new(50,(50+sk+50+sk+25+25+sk+50+sk+50),sk, sk)).background_(Color.black).action_({
arg obj;
var dist;
dist=obj.value.linlin(0,1,1,10);
dist.postln;
~dist=dist;
~log1.(dist.asString);
});
~st16=StaticText(~vw1,Rect(50,(50+sk+50+sk+25+25+sk+50+sk+50+sk),sk+20,sk)).string_("distance")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',16));
);
(
~s117=Knob.new(~vw1, Rect.new(150,(50+sk+50+sk+25+25+sk+50+sk+50), sk)).background_(Color.black).action_({
arg obj;
var value;
value=obj.value.linexp(0,1,0.01pi,pi).postln;
~spinbind=value;
~log1.(value.asString);
});
~s117=StaticText(~vw1,Rect(150,(50+sk+50+sk+25+25+sk+50+sk+50+sk),sk+20,sk)).string_("spinbind")
.stringColor_(Color.white).background_(Color.black).font_(Font('Arial',16));
)
}.defer
);
}); Tdef(\drone).play;
}
)




////envelope sig
//(~ne=1.neg;~arraye=56.collect{~ne=~ne+1;2.pow(~ne/56)};
//~signalSizee = 2048*1);
//////////pbind stack env
/*signal = Signal.sineFill(~signalSizee, ~arraye, [0]);
signal = signal.rotate(signal.size div: 2);
peak = signal.abs.maxIndex.max(1);
rip = Env([0,1,1,0],[1,1,1],[4.neg,0,4]).asSignal(~signalSizee);
rip = rip * (1 + (signal / tremolo));
rip = rip.normalize;
peak = peak.min(signal.size - 2).max(1);
times =Array.fill(signal.size - peak - 1, hold / (signal.size - peak - 1));
enva = Env(rip.asArray, times);
env = EnvGen.ar(enva,levelScale:gain,doneAction:2);*/



/*///rhythm
({var x,y,z,n=0,time=32.reciprocal,bx,by,bz,beat=4;~dursum=0;
beat.do{
x=beat*cos(~elevation.[n])*cos(~azimuth.[n]);
y=beat*cos(~elevation.[n])*sin(~azimuth.[n]);
z=beat*sin(~elevation.[n]);
bx=2.pow(x).round(time);
by=2.pow(y).round(time);
bz=2.pow(z).round(time);
~dursum=~dursum+bx+by+bz;
n=n+1};
}.value
);	*/
//0.1.wait;
/*(
{var rrot,n=0,beats=4,r=0;
Routine({loop{
~azry=[];~elry=[];n=0;
beats.do{
rrot=Spherical(~rate,~azimuth.[n],~elevation.[n]).rotateXY(r.lag2(~frames));
r=(r+128.reciprocal).wrap(0,2pi);
~azry=~azry++rrot.theta;
~elry=~elry++rrot.phi;
n=n+1};
(15).wait;
};
}).play;
}.defer
);*/
/*(
{var x,y,z,beat=4,bx,by,bz,time=32.reciprocal,n=0;
Routine({loop{
~dur=[];n=0;
beat.do{
x=beat*cos(~elry.[n])*cos(~azry.[n]);
y=beat*cos(~elry.[n])*sin(~azry.[n]);
z=beat*sin(~elry.[n]);
bx=2.pow(x).round(time);
by=2.pow(y).round(time);
bz=2.pow(z).round(time);
~dur=~dur++bx++by++bz;
n=n+1};
~dur=~dur/8;
~seq=Pseq(~dur,inf).asStream;
(~frames).wait;
};
}).play;
}.defer
);*/
/*(
{var rot;
Routine({loop{
~synth.set(\attack,~attack,\decay,~decay,\rate,~seq.next);
(~seq.next).wait;
};
}).play;
}.defer);*/


/////other arrays
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////spaces
/*
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////tetrahedron
(
~azimuth=[45.degrad,135.neg.degrad,45.neg.degrad,135.degrad];
~elevation=[35.264390.neg.degrad,35.264390.neg.degrad,35.264390.degrad,35.264390.degrad];
);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////cube
(
~azimuth=[45.degrad,135.degrad,45.neg.degrad,135.neg.degrad,45.degrad,135.degrad,45.neg.degrad,135.neg.degrad];
~elevation=[35.264390.neg.degrad,35.264390.neg.degrad,35.264390.neg.degrad,35.264390.neg.degrad,35.264390.degrad,35.264390.degrad,35.264390.degrad,35.264390.degrad];
)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////octahedron
(
~azimuth=[0.degrad,0.degrad,90.degrad,180.degrad,90.neg.degrad,0.degrad];
~elevation=[90.neg.degrad,0.degrad,0.degrad,0.degrad,0.degrad,90.degrad];
)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////icosahedron
(
~azimuth=[90.degrad,90.neg.degrad,0.degrad,180.degrad,58.28.degrad,121.72.degrad,121.72.neg.degrad,58.neg.degrad,90.degrad,90.neg.degrad,0.degrad,180.degrad];
~elevation=[58.28.neg.degrad,58.28.neg.degrad,31.72.neg.degrad,31.72.neg.degrad,0.degrad,0.degrad,0.degrad,0.degrad,58.28.degrad,58.28.degrad,31.72.degrad,31.72.degrad];
)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////dodecahedron
(
~azimuth=[45.degrad,135.neg.degrad,135.degrad,45.neg.degrad,90.degrad,90.neg.degrad,0.degrad,180.degrad,45.degrad,135.neg.degrad,135.degrad,45.neg.degrad,90.degrad,
	90.neg.degrad,69.09.degrad,110.91.degrad,110.91.neg.degrad,69.09.neg.degrad,0.degrad,180.degrad];

~elevation=[35.26.neg.degrad,35.26.neg.degrad,35.26.neg.degrad,35.26.neg.degrad,69.09.neg.degrad,69.09.neg.degrad,20.91.neg.degrad,20.91.neg.degrad,
	35.26.degrad,35.26.degrad,35.26.degrad,35.26.degrad,69.09.degrad,69.09.degrad,0.degrad,0.degrad,0.degrad,0.degrad,20.91.degrad,20.91.degrad]
)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Rhombic dodecahedron
(
~azimuth=[0.degrad,45.degrad,135.neg.degrad,135.degrad,45.neg.degrad,0.degrad,180.degrad,90.degrad,90.neg.degrad,0.degrad,
	45.degrad,135.neg.degrad,135.degrad,45.neg.degrad];
~elevation=[90.neg.degrad,35.264390.neg.degrad,35.264390.neg.degrad,35.264390.neg.degrad,35.264390.neg.degrad,0.degrad
	,0.degrad,0.degrad,0.degrad,90.degrad,35.264390.degrad,35.264390.degrad,35.264390.degrad,35.264390.degrad];
)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////cuboctahedron
(
~azimuth=[0.degrad,90.degrad,180.degrad,90.neg.degrad,45.degrad,135.degrad,45.neg.degrad,135.neg.degrad,
	0.degrad,90.degrad,180.degrad,90.neg.degrad];
~elevation=[45.neg.degrad,45.neg.degrad,45.neg.degrad,45.neg.degrad,0.degrad,0.degrad,0.degrad,0.degrad,
	45.degrad,45.degrad,45.degrad,45.degrad];
)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Rhombic Triacontahedron
(
~azimuth=[0.degrad,0.degrad,72.degrad,144.degrad,144.neg.degrad,72.neg.degrad,36.degrad,108.degrad,180.degrad,108.neg.degrad,36.neg.degrad,
	0.degrad,72.degrad,144.degrad,144.neg.degrad,72.neg.degrad,36.degrad,108.degrad,180.degrad,108.neg.degrad,36.neg.degrad,
	0.degrad,72.degrad,144.degrad,144.neg.degrad,72.neg.degrad,36.degrad,108.degrad,180.degrad,108.neg.degrad,36.neg.degrad,0.degrad];

~elevation=[90.neg.degrad,52.6.neg.degrad,52.6.neg.degrad,52.6.neg.degrad,52.6.neg.degrad,52.6.neg.degrad,26.6.neg.degrad,26.6.neg.degrad,26.6.neg.degrad,26.6.neg.degrad,26.6.neg.degrad,10.8.neg.degrad,10.8.neg.degrad,10.8.neg.degrad,10.8.neg.degrad,10.8.neg.degrad,52.6.degrad,52.6.degrad,52.6.degrad,52.6.degrad,52.6.degrad,26.6.degrad,26.6.degrad,26.6.degrad,26.6.degrad,26.6.degrad,10.8.degrad,10.8.degrad,10.8.degrad,10.8.degrad,10.8.degrad,90.degrad];

)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////icosidodecahedron
(
~azimuth=[18.degrad,90.degrad,162.degrad,126.neg.degrad,54.neg.degrad,54.degrad,126.degrad,162.neg.degrad,90.neg.degrad,18.neg.degrad,
	0.degrad,36.degrad,72.degrad,108.degrad,144.degrad,180.degrad,144.neg.degrad,108.neg.degrad,72.neg.degrad,36.neg.degrad,
	54.degrad,126.degrad,162.neg.degrad,90.neg.degrad,18.neg.degrad,18.degrad,90.degrad,162.degrad,126.neg.degrad,54.neg.degrad];

~elevation=[58.283.degrad,58.283.degrad,58.283.degrad,58.283.degrad,58.283.degrad,58.283.neg.degrad,58.283.neg.degrad,58.283.neg.degrad,58.283.neg.degrad,58.283.neg.degrad,0.degrad,0.degrad,0.degrad,0.degrad,0.degrad,0.degrad,0.degrad,0.degrad,0.degrad,0.degrad,
37.717.degrad,37.717.degrad,37.717.degrad,37.717.degrad,37.717.degrad,37.717.neg.degrad,37.717.neg.degrad,37.717.neg.degrad,37.717.neg.degrad,37.717.neg.degrad];
)*/