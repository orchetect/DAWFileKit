//
//  DAWFileKit Cubase TrackArchive Tests.swift
//  DAWFileKitTests
//
//  Created by Steffan Andrews on 2018-11-02.
//  Copyright © 2018 Steffan Andrews. All rights reserved.
//

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit


// MARK: XML_BasicMarkers

fileprivate let XML_BasicMarkers = """
<?xml version="1.0" encoding="utf-8"?>
<tracklist2>
   <list name="track" type="obj">
	  <obj class="MMarkerTrackEvent" ID="140262019346320">
		 <int name="Flags" value="1"/>
		 <float name="Start" value="0"/>
		 <float name="Length" value="370861.849999999976716935634613037109375"/>
		 <obj class="MListNode" name="Node" ID="140262019587472">
			<string name="Name" value="Cues" wide="true"/>
			<member name="Domain">
			   <int name="Type" value="0"/>
			   <obj class="MTempoTrackEvent" name="Tempo Track" ID="140263632495712">
				  <list name="TempoEvent" type="obj">
					 <obj class="MTempoEvent" ID="105553189067552">
						<float name="BPM" value="115"/>
						<float name="PPQ" value="0"/>
					 </obj>
					 <obj class="MTempoEvent" ID="105553188929872">
						<float name="BPM" value="120"/>
						<float name="PPQ" value="7680"/>
					 </obj>
					 <obj class="MTempoEvent" ID="105553189848944">
						<float name="BPM" value="155.74200439453125"/>
						<float name="PPQ" value="9600"/>
					 </obj>
				  </list>
				  <float name="RehearsalTempo" value="120"/>
				  <member name="Additional Attributes">
					 <int name="TTlB" value="80"/>
					 <int name="TTuB" value="200"/>
					 <int name="TLID" value="1"/>
					 <obj class="MTrackVariationCollection" name="TVCi" ID="105553181054544">
						<int name="ownership" value="2"/>
						<list name="obj" type="obj">
						   <obj class="MTrackVariation" ID="105553242916736">
							  <string name="name" value="v1" wide="true"/>
							  <int name="variationID" value="0"/>
						   </obj>
						</list>
					 </obj>
					 <int name="Lock" value="0"/>
					 <int name="Eths" value="-260498236"/>
				  </member>
			   </obj>
			   <obj class="MSignatureTrackEvent" name="Signature Track" ID="140262021476400">
				  <list name="SignatureEvent" type="obj">
					 <obj class="MTimeSignatureEvent" ID="105553193214112">
						<int name="Flags" value="8"/>
						<float name="Start" value="0"/>
						<float name="Length" value="1"/>
						<int name="Bar" value="0"/>
						<int name="Numerator" value="4"/>
						<int name="Denominator" value="4"/>
						<int name="Position" value="0"/>
					 </obj>
				  </list>
				  <member name="Additional Attributes">
					 <int name="TLID" value="1"/>
					 <int name="LocS" value="0"/>
					 <obj class="MTrackVariationCollection" name="TVCi" ID="105553181140784">
						<int name="ownership" value="2"/>
						<list name="obj" type="obj">
						   <obj class="MTrackVariation" ID="105553242924032">
							  <string name="name" value="v1" wide="true"/>
							  <int name="variationID" value="0"/>
						   </obj>
						</list>
					 </obj>
					 <int name="Eths" value="-260498236"/>
				  </member>
			   </obj>
			</member>
			<list name="Events" type="obj">
			   <obj class="MRangeMarkerEvent" ID="105553185396480">
				  <float name="Start" value="1920"/>
				  <float name="Length" value="1920"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="Cycle Marker Name 1" wide="true"/>
				  <int name="ID" value="1"/>
			   </obj>
			</list>
		 </obj>
		 <member name="Additional Attributes">
			<int name="Eths" value="-260498236"/>
		 </member>
		 <obj class="MTrack" name="Track Device" ID="105553135614736">
			<int name="Connection Type" value="2"/>
		 </obj>
	  </obj>
	  <obj class="MMarkerTrackEvent" ID="140262019105296">
		 <int name="Flags" value="1"/>
		 <float name="Start" value="0"/>
		 <float name="Length" value="370861.849999999976716935634613037109375"/>
		 <obj class="MListNode" name="Node" ID="140262019536720">
			<string name="Name" value="Stems" wide="true"/>
			<member name="Domain">
			   <int name="Type" value="0"/>
			   <obj name="Tempo Track" ID="140263632495712"/>
			   <obj name="Signature Track" ID="140262021476400"/>
			</member>
			<list name="Events" type="obj">
			   <obj class="MRangeMarkerEvent" ID="105553185397632">
				  <float name="Start" value="3840"/>
				  <float name="Length" value="1920"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="Cycle Marker Name 2" wide="true"/>
				  <int name="ID" value="1"/>
			   </obj>
			</list>
		 </obj>
		 <member name="Additional Attributes">
			<int name="TLID" value="1"/>
			<int name="Eths" value="-260498236"/>
		 </member>
		 <obj class="MTrack" name="Track Device" ID="105553135614496">
			<int name="Connection Type" value="2"/>
		 </obj>
	  </obj>
	  <obj class="MMarkerTrackEvent" ID="140262021295152">
		 <int name="Flags" value="1"/>
		 <float name="Start" value="0"/>
		 <float name="Length" value="300.30000000000001136868377216160297393798828125"/>
		 <obj class="MListNode" name="Node" ID="140263632453152">
			<string name="Name" value="TC Markers" wide="true"/>
			<member name="Domain">
			   <int name="Type" value="1"/>
			   <float name="Period" value="1"/>
			</member>
			<list name="Events" type="obj">
			   <obj class="MMarkerEvent" ID="105553185397504">
				  <float name="Start" value="0.573913037776947021484375"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="Marker at One Hour" wide="true"/>
				  <int name="ID" value="1"/>
			   </obj>
			</list>
		 </obj>
		 <member name="Additional Attributes">
			<int name="TLID" value="1"/>
			<int name="Eths" value="-260498236"/>
		 </member>
		 <obj class="MTrack" name="Track Device" ID="105553135614256">
			<int name="Connection Type" value="2"/>
		 </obj>
	  </obj>
   </list>
   <obj class="ExternalRouting" name="ExternalRouting" ID="105553242290048">
	  <member name="Audio">
	  </member>
   </obj>
   <obj class="PArrangeSetup" name="Setup" ID="140263649579728">
	  <member name="Start">
		 <float name="Time" value="3603.02608696222296202904544770717620849609375"/>
		 <member name="Domain">
			<int name="Type" value="1"/>
			<float name="Period" value="1"/>
		 </member>
	  </member>
	  <member name="Length">
		 <float name="Time" value="300.30000000000001136868377216160297393798828125"/>
		 <member name="Domain">
			<int name="Type" value="1"/>
			<float name="Period" value="1"/>
		 </member>
	  </member>
	  <int name="BarOffset" value="0"/>
	  <int name="FrameType" value="12"/>
	  <int name="TimeType" value="0"/>
	  <float name="SampleRate" value="48000"/>
	  <int name="SampleSize" value="24"/>
	  <int name="SampleFormatSize" value="3"/>
	  <int name="PanLaw" value="6"/>
	  <int name="RecordFile" value="1"/>
	  <member name="RecordFileType">
		 <int name="MacType" value="1463899717"/>
		 <string name="DosType" value="wav" wide="true"/>
		 <string name="UnixType" value="wav" wide="true"/>
		 <string name="Name" value="Broadcast Wave File" wide="true"/>
	  </member>
	  <int name="VolumeMax" value="1"/>
	  <int name="HmtType" value="0"/>
	  <int name="HmtDepth" value="100"/>
   </obj>
</tracklist2>
"""

// MARK: XML_MusicalAndLinearTest

fileprivate let XML_MusicalAndLinearTest = """
<?xml version="1.0" encoding="utf-8"?>
<tracklist2>
   <list name="track" type="obj">
	  <obj class="MMarkerTrackEvent" ID="140364308634064">
		 <int name="Flags" value="1"/>
		 <float name="Start" value="0"/>
		 <float name="Length" value="4435075.56900000013411045074462890625"/>
		 <obj class="MListNode" name="Node" ID="140364308634368">
			<string name="Name" value="Markers" wide="true"/>
			<member name="Domain">
			   <int name="Type" value="0"/>
			   <obj class="MTempoTrackEvent" name="Tempo Track" ID="140364308633744">
				  <list name="TempoEvent" type="obj">
					 <obj class="MTempoEvent" ID="105553193416480">
						<float name="BPM" value="120"/>
						<float name="PPQ" value="0"/>
					 </obj>
					 <obj class="MTempoEvent" ID="105553194667856">
						<float name="BPM" value="150"/>
						<float name="PPQ" value="7680"/>
					 </obj>
					 <obj class="MTempoEvent" ID="105553193305968">
						<float name="BPM" value="134.274993896484375"/>
						<float name="PPQ" value="15360"/>
					 </obj>
					 <obj class="MTempoEvent" ID="105553193310336">
						<float name="BPM" value="99.99999237060546875"/>
						<float name="PPQ" value="23040"/>
					 </obj>
					 <obj class="MTempoEvent" ID="105553194747424">
						<float name="BPM" value="99.99999237060546875"/>
						<float name="PPQ" value="24960"/>
					 </obj>
					 <obj class="MTempoEvent" ID="105553194747536">
						<float name="BPM" value="199.9999847412109375"/>
						<float name="PPQ" value="32640"/>
						<int name="Func" value="1"/>
					 </obj>
					 <obj class="MTempoEvent" ID="105553193319184">
						<float name="BPM" value="135"/>
						<float name="PPQ" value="36480"/>
					 </obj>
				  </list>
				  <float name="RehearsalTempo" value="120"/>
				  <member name="Additional Attributes">
					 <int name="TTlB" value="80"/>
					 <int name="TTuB" value="210"/>
					 <int name="TLID" value="1"/>
					 <obj class="MTrackVariationCollection" name="TVCi" ID="105553167538128">
						<int name="ownership" value="2"/>
						<list name="obj" type="obj">
						   <obj class="MTrackVariation" ID="105553175921728">
							  <string name="name" value="v1" wide="true"/>
							  <int name="variationID" value="0"/>
						   </obj>
						</list>
					 </obj>
					 <int name="Lock" value="0"/>
					 <int name="Eths" value="-260498236"/>
				  </member>
			   </obj>
			   <obj class="MSignatureTrackEvent" name="Signature Track" ID="140364308633152">
				  <list name="SignatureEvent" type="obj">
					 <obj class="MTimeSignatureEvent" ID="105553189757856">
						<int name="Flags" value="8"/>
						<float name="Start" value="0"/>
						<float name="Length" value="1"/>
						<int name="Bar" value="0"/>
						<int name="Numerator" value="4"/>
						<int name="Denominator" value="4"/>
						<int name="Position" value="0"/>
					 </obj>
				  </list>
				  <member name="Additional Attributes">
					 <int name="TLID" value="1"/>
					 <int name="LocS" value="0"/>
					 <obj class="MTrackVariationCollection" name="TVCi" ID="105553167545424">
						<int name="ownership" value="2"/>
						<list name="obj" type="obj">
						   <obj class="MTrackVariation" ID="105553175921984">
							  <string name="name" value="v1" wide="true"/>
							  <int name="variationID" value="0"/>
						   </obj>
						</list>
					 </obj>
					 <int name="Eths" value="-260498236"/>
				  </member>
			   </obj>
			</member>
			<list name="Events" type="obj">
			   <obj class="MMarkerEvent" ID="105553131021696">
				  <float name="Start" value="1920"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="1" wide="true"/>
				  <int name="ID" value="1"/>
			   </obj>
			   <obj class="MRangeMarkerEvent" ID="105553129419904">
				  <float name="Start" value="3840"/>
				  <float name="Length" value="1920"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="2" wide="true"/>
				  <int name="ID" value="1"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553197733760">
				  <float name="Start" value="9600"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="3" wide="true"/>
				  <int name="ID" value="2"/>
			   </obj>
			   <obj class="MRangeMarkerEvent" ID="105553197737856">
				  <float name="Start" value="11520"/>
				  <float name="Length" value="1920"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="4" wide="true"/>
				  <int name="ID" value="2"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553131823360">
				  <float name="Start" value="17280"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="5" wide="true"/>
				  <int name="ID" value="3"/>
			   </obj>
			   <obj class="MRangeMarkerEvent" ID="105553197763200">
				  <float name="Start" value="19200"/>
				  <float name="Length" value="1920"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="6" wide="true"/>
				  <int name="ID" value="3"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553131014400">
				  <float name="Start" value="26880"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="7" wide="true"/>
				  <int name="ID" value="5"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553132813184">
				  <float name="Start" value="30720"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="8" wide="true"/>
				  <int name="ID" value="6"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553197764608">
				  <float name="Start" value="34560"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="9" wide="true"/>
				  <int name="ID" value="7"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553197766528">
				  <float name="Start" value="3268111.5"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="10" wide="true"/>
				  <int name="ID" value="4"/>
			   </obj>
			</list>
		 </obj>
		 <member name="Additional Attributes">
			<int name="Eths" value="-260498236"/>
		 </member>
		 <obj class="MTrack" name="Track Device" ID="105553147418960">
			<int name="Connection Type" value="2"/>
		 </obj>
	  </obj>
	  <obj class="MMarkerTrackEvent" ID="140365076840048">
		 <int name="Flags" value="1"/>
		 <float name="Start" value="0"/>
		 <float name="Length" value="4105.777426566202848334796726703643798828125"/>
		 <obj class="MListNode" name="Node" ID="140365076826960">
			<string name="Name" value="TC Markers" wide="true"/>
			<member name="Domain">
			   <int name="Type" value="1"/>
			   <float name="Period" value="1"/>
			</member>
			<list name="Events" type="obj">
			   <obj class="MMarkerEvent" ID="105553197671424">
				  <float name="Start" value="2"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="1" wide="true"/>
				  <int name="ID" value="1"/>
			   </obj>
			   <obj class="MRangeMarkerEvent" ID="105553129060992">
				  <float name="Start" value="4"/>
				  <float name="Length" value="2"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="2" wide="true"/>
				  <int name="ID" value="1"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553197733632">
				  <float name="Start" value="9.60000002384185791015625"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="3" wide="true"/>
				  <int name="ID" value="2"/>
			   </obj>
			   <obj class="MRangeMarkerEvent" ID="105553197738624">
				  <float name="Start" value="11.2000000476837158203125"/>
				  <float name="Length" value="1.60000002384185791015625"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="4" wide="true"/>
				  <int name="ID" value="2"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553131823616">
				  <float name="Start" value="16.18737685680389404296875"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="5" wide="true"/>
				  <int name="ID" value="3"/>
			   </obj>
			   <obj class="MRangeMarkerEvent" ID="105553197763456">
				  <float name="Start" value="17.9747536182403564453125"/>
				  <float name="Length" value="1.78737676143646240234375"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="6" wide="true"/>
				  <int name="ID" value="3"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553197769856">
				  <float name="Start" value="26.09168549253235624973967787809669971466064453125"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="7" wide="true"/>
				  <int name="ID" value="5"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553131020288">
				  <float name="Start" value="29.321819210535647215465360204689204692840576171875"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="8" wide="true"/>
				  <int name="ID" value="6"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553131558144">
				  <float name="Start" value="31.80372072521610249395962455309927463531494140625"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="9" wide="true"/>
				  <int name="ID" value="7"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553197735552">
				  <float name="Start" value="3025.255131955798788112588226795196533203125"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="10" wide="true"/>
				  <int name="ID" value="4"/>
			   </obj>
			</list>
		 </obj>
		 <member name="Additional Attributes">
			<int name="Eths" value="-260498236"/>
		 </member>
		 <obj class="MTrack" name="Track Device" ID="105553147405216">
			<int name="Connection Type" value="2"/>
		 </obj>
	  </obj>
   </list>
   <obj class="ExternalRouting" name="ExternalRouting" ID="105553117095104">
	  <member name="Audio">
	  </member>
   </obj>
   <obj class="PArrangeSetup" name="Setup" ID="140365636222688">
	  <member name="Start">
		 <float name="Time" value="3600"/>
		 <member name="Domain">
			<int name="Type" value="1"/>
			<float name="Period" value="1"/>
		 </member>
	  </member>
	  <member name="Length">
		 <float name="Time" value="4105.777426566202848334796726703643798828125"/>
		 <member name="Domain">
			<int name="Type" value="1"/>
			<float name="Period" value="1"/>
		 </member>
	  </member>
	  <int name="BarOffset" value="0"/>
	  <int name="FrameType" value="5"/>
	  <int name="TimeType" value="0"/>
	  <float name="SampleRate" value="48000"/>
	  <int name="SampleSize" value="24"/>
	  <int name="SampleFormatSize" value="3"/>
	  <int name="PanLaw" value="6"/>
	  <int name="RecordFile" value="1"/>
	  <member name="RecordFileType">
		 <int name="MacType" value="1463899717"/>
		 <string name="DosType" value="wav" wide="true"/>
		 <string name="UnixType" value="wav" wide="true"/>
		 <string name="Name" value="Broadcast Wave File" wide="true"/>
	  </member>
	  <int name="VolumeMax" value="1"/>
	  <int name="HmtType" value="0"/>
	  <int name="HmtDepth" value="100"/>
   </obj>
</tracklist2>
"""

// MARK: XML_RoundingTest

fileprivate let XML_RoundingTest = """
<?xml version="1.0" encoding="utf-8"?>
<tracklist2>
   <list name="track" type="obj">
	  <obj class="MMarkerTrackEvent" ID="140606467401840">
		 <int name="Flags" value="1"/>
		 <float name="Start" value="0"/>
		 <float name="Length" value="3941546.33000000007450580596923828125"/>
		 <obj class="MListNode" name="Node" ID="140608863340592">
			<string name="Name" value="Markers" wide="true"/>
			<member name="Domain">
			   <int name="Type" value="0"/>
			   <obj class="MTempoTrackEvent" name="Tempo Track" ID="140606467399392">
				  <list name="TempoEvent" type="obj">
					 <obj class="MTempoEvent" ID="105553183621456">
						<float name="BPM" value="120"/>
						<float name="PPQ" value="0"/>
					 </obj>
				  </list>
				  <float name="RehearsalTempo" value="120"/>
				  <member name="Additional Attributes">
					 <int name="TTlB" value="80"/>
					 <int name="TTuB" value="210"/>
					 <int name="TLID" value="1"/>
					 <obj class="MTrackVariationCollection" name="TVCi" ID="105553178216416">
						<int name="ownership" value="2"/>
						<list name="obj" type="obj">
						   <obj class="MTrackVariation" ID="105553171264384">
							  <string name="name" value="v1" wide="true"/>
							  <int name="variationID" value="0"/>
						   </obj>
						</list>
					 </obj>
					 <int name="Lock" value="0"/>
					 <int name="Eths" value="-260498236"/>
				  </member>
			   </obj>
			   <obj class="MSignatureTrackEvent" name="Signature Track" ID="140608863290512">
				  <list name="SignatureEvent" type="obj">
					 <obj class="MTimeSignatureEvent" ID="105553197806528">
						<int name="Flags" value="8"/>
						<float name="Start" value="0"/>
						<float name="Length" value="1"/>
						<int name="Bar" value="0"/>
						<int name="Numerator" value="4"/>
						<int name="Denominator" value="4"/>
						<int name="Position" value="0"/>
					 </obj>
				  </list>
				  <member name="Additional Attributes">
					 <int name="TLID" value="1"/>
					 <int name="LocS" value="0"/>
					 <obj class="MTrackVariationCollection" name="TVCi" ID="105553178216608">
						<int name="ownership" value="2"/>
						<list name="obj" type="obj">
						   <obj class="MTrackVariation" ID="105553171254848">
							  <string name="name" value="v1" wide="true"/>
							  <int name="variationID" value="0"/>
						   </obj>
						</list>
					 </obj>
					 <int name="Eths" value="-260498236"/>
				  </member>
			   </obj>
			</member>
			<list name="Events" type="obj">
			   <obj class="MMarkerEvent" ID="105553188656896">
				  <float name="Start" value="1888"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="Exactly 1 frame before" wide="true"/>
				  <int name="ID" value="3"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553188685568">
				  <float name="Start" value="1919.5"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="1 PPQ before" wide="true"/>
				  <int name="ID" value="2"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553188542464">
				  <float name="Start" value="1919.97600000000011277734301984310150146484375"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="Just Prior" wide="true"/>
				  <int name="ID" value="4"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553189033088">
				  <float name="Start" value="1920"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="Exact" wide="true"/>
				  <int name="ID" value="1"/>
			   </obj>
			</list>
		 </obj>
		 <member name="Additional Attributes">
			<int name="Eths" value="-260498236"/>
		 </member>
		 <obj class="MTrack" name="Track Device" ID="105553141415936">
			<int name="Connection Type" value="2"/>
		 </obj>
	  </obj>
	  <obj class="MMarkerTrackEvent" ID="140606466823216">
		 <int name="Flags" value="1"/>
		 <float name="Start" value="0"/>
		 <float name="Length" value="4105.777426566202848334796726703643798828125"/>
		 <obj class="MListNode" name="Node" ID="140608862789056">
			<string name="Name" value="TC Markers" wide="true"/>
			<member name="Domain">
			   <int name="Type" value="1"/>
			   <float name="Period" value="1"/>
			</member>
			<list name="Events" type="obj">
			   <obj class="MMarkerEvent" ID="105553188661376">
				  <float name="Start" value="1.9666666666666665630458510349853895604610443115234"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="Exactly 1 frame before" wide="true"/>
				  <int name="ID" value="2"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553188662144">
				  <float name="Start" value="1.9994791666666666962726139900041744112968444824219"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="1 PPQ before" wide="true"/>
				  <int name="ID" value="3"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553188627712">
				  <float name="Start" value="1.9999750000000000582645043323282152414321899414062"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="Just Prior" wide="true"/>
				  <int name="ID" value="4"/>
			   </obj>
			   <obj class="MMarkerEvent" ID="105553188737664">
				  <float name="Start" value="2"/>
				  <float name="Length" value="0"/>
				  <member name="Additional Attributes">
					 <member name="tAMA">
					 </member>
				  </member>
				  <string name="Name" value="Exact" wide="true"/>
				  <int name="ID" value="1"/>
			   </obj>
			</list>
		 </obj>
		 <member name="Additional Attributes">
			<int name="Eths" value="-260498236"/>
		 </member>
		 <obj class="MTrack" name="Track Device" ID="105553141416176">
			<int name="Connection Type" value="2"/>
		 </obj>
	  </obj>
   </list>
   <obj class="ExternalRouting" name="ExternalRouting" ID="105553171935168">
	  <member name="Audio">
	  </member>
   </obj>
   <obj class="PArrangeSetup" name="Setup" ID="140606446871488">
	  <member name="Start">
		 <float name="Time" value="3600"/>
		 <member name="Domain">
			<int name="Type" value="1"/>
			<float name="Period" value="1"/>
		 </member>
	  </member>
	  <member name="Length">
		 <float name="Time" value="4105.777426566202848334796726703643798828125"/>
		 <member name="Domain">
			<int name="Type" value="1"/>
			<float name="Period" value="1"/>
		 </member>
	  </member>
	  <int name="BarOffset" value="0"/>
	  <int name="FrameType" value="5"/>
	  <int name="TimeType" value="5"/>
	  <float name="SampleRate" value="48000"/>
	  <int name="SampleSize" value="24"/>
	  <int name="SampleFormatSize" value="3"/>
	  <int name="PanLaw" value="6"/>
	  <int name="RecordFile" value="1"/>
	  <member name="RecordFileType">
		 <int name="MacType" value="1463899717"/>
		 <string name="DosType" value="wav" wide="true"/>
		 <string name="UnixType" value="wav" wide="true"/>
		 <string name="Name" value="Broadcast Wave File" wide="true"/>
	  </member>
	  <int name="VolumeMax" value="1"/>
	  <int name="HmtType" value="0"/>
	  <int name="HmtDepth" value="100"/>
   </obj>
</tracklist2>
"""


class DAWFileKit_Cubase_TrackArchive_Read_Tests: XCTestCase {

	override func setUp() { }
	override func tearDown() { }
	
	func testBasicMarkers() {
		
		guard let data = XML_BasicMarkers.toData()
			else { XCTFail() ; return }
		
		guard let trackArchive = Cubase.TrackArchive(fromData: data)
			else { XCTFail() ; return }
		
		// ---- main ----
		
		// frame rate
		XCTAssertEqual(trackArchive.main.frameRate, ._23_976)
		
		// start timecode
		XCTAssertEqual(trackArchive.main.startTimecode?.components,
					   TCC(d: 0, h: 00, m: 59, s: 59, f: 10, sf: 19))
		
		// length timecode
		XCTAssertEqual(trackArchive.main.lengthTimecode?.components,
					   TCC(d: 0, h: 00, m: 05, s: 00, f: 00, sf: 00))
		
		// TimeType - not implemented yet
		
		// bar offset
		XCTAssertEqual(trackArchive.main.barOffset, 0)
		
		// sample rate
		XCTAssertEqual(trackArchive.main.sampleRate, 48000.0)
		
		// bit depth
		XCTAssertEqual(trackArchive.main.bitDepth, 24)
		
		// SampleFormatSize - not implemented yet
		
		// RecordFile - not implemented yet
		
		// RecordFileType ... - not implemented yet
		
		// PanLaw - not implemented yet
		
		// VolumeMax - not implemented yet
		
		// HmtType - not implemented yet
		
		// HMTDepth
		XCTAssertEqual(trackArchive.main.HMTDepth, 100)
		
		// ---- tempo track ----
		
		XCTAssertEqual(trackArchive.tempoTrack.events.count, 3)
		
		XCTAssertEqual(trackArchive.tempoTrack.events[safe: 0]?.tempo, 115.0)
		XCTAssertEqual(trackArchive.tempoTrack.events[safe: 0]?.type, .jump)
		
		XCTAssertEqual(trackArchive.tempoTrack.events[safe: 1]?.tempo, 120.0)
		XCTAssertEqual(trackArchive.tempoTrack.events[safe: 1]?.type, .jump)
		
		XCTAssertEqual(trackArchive.tempoTrack.events[safe: 2]?.tempo, 155.74200439453125)
		XCTAssertEqual(trackArchive.tempoTrack.events[safe: 2]?.type, .jump)
		
		
		// ---- tracks ----
		
		XCTAssertEqual(trackArchive.tracks?.count, 3)
		
		// track 1 - musical mode
		
		let track1 = trackArchive.tracks?[0] as? Cubase.TrackArchive.MarkerTrack
		XCTAssertNotNil(track1)
		
		XCTAssertEqual(track1?.name, "Cues")
		
		let track1event1 = track1?.events[safe: 0] as? Cubase.TrackArchive.CycleMarker
		XCTAssertNotNil(track1event1)
		
		XCTAssertEqual(track1event1?.name, "Cycle Marker Name 1")
		
		XCTAssertEqual(track1event1?.startTimecode.components,
					   TCC(d: 0, h: 01, m: 00, s: 01, f: 12, sf: 22))
		XCTAssertEqual(track1event1?.lengthTimecode.components,
					   TCC(d: 0, h: 00, m: 00, s: 02, f: 02, sf: 03))
		
		// track 2 - musical mode
		
		let track2 = trackArchive.tracks?[1] as? Cubase.TrackArchive.MarkerTrack
		XCTAssertNotNil(track2)
		
		XCTAssertEqual(track2?.name, "Stems")
		
		let track2event1 = track2?.events[safe: 0] as? Cubase.TrackArchive.CycleMarker
		XCTAssertNotNil(track2event1)
		
		XCTAssertEqual(track2event1?.name, "Cycle Marker Name 2")
		
		XCTAssertEqual(track2event1?.startTimecode.components,
					   TCC(d: 0, h: 01, m: 00, s: 03, f: 14, sf: 25))
		XCTAssertEqual(track2event1?.lengthTimecode.components,
					   TCC(d: 0, h: 00, m: 00, s: 02, f: 02, sf: 03))
		
		// track 3 - linear mode (absolute time)
		
		let track3 = trackArchive.tracks?[2] as? Cubase.TrackArchive.MarkerTrack
		XCTAssertNotNil(track3)
		
		XCTAssertEqual(track3?.name, "TC Markers")
		
		let track3event1 = track3?.events[safe: 0] as? Cubase.TrackArchive.Marker
		XCTAssertNotNil(track3event1)
		
		XCTAssertEqual(track3event1?.name, "Marker at One Hour")
		XCTAssertEqual(track3event1?.startTimecode.components,
					   TCC(d: 0, h: 01, m: 00, s: 00, f: 00, sf: 00))
		
	}
	
	func testMusicalAndLinearTest() {
		
		guard let data = XML_MusicalAndLinearTest.toData()
			else { XCTFail() ; return }
		
		guard let trackArchive = Cubase.TrackArchive(fromData: data)
			else { XCTFail() ; return }
		
		// ---- tracks ----
		
		XCTAssertEqual(trackArchive.tracks?.count, 2)
		
		// track 1 - musical mode
		
		let track1 = trackArchive.tracks?[0] as? Cubase.TrackArchive.MarkerTrack
		XCTAssertNotNil(track1)
		
		let track1event1  = track1?.events[safe: 0] as? Cubase.TrackArchive.Marker
		let track1event2  = track1?.events[safe: 1] as? Cubase.TrackArchive.CycleMarker
		let track1event3  = track1?.events[safe: 2] as? Cubase.TrackArchive.Marker
		let track1event4  = track1?.events[safe: 3] as? Cubase.TrackArchive.CycleMarker
		let track1event5  = track1?.events[safe: 4] as? Cubase.TrackArchive.Marker
		let track1event6  = track1?.events[safe: 5] as? Cubase.TrackArchive.CycleMarker
		let track1event7  = track1?.events[safe: 6] as? Cubase.TrackArchive.Marker
		let track1event8  = track1?.events[safe: 7] as? Cubase.TrackArchive.Marker
		let track1event9  = track1?.events[safe: 8] as? Cubase.TrackArchive.Marker
		let track1event10 = track1?.events[safe: 9] as? Cubase.TrackArchive.Marker
		XCTAssertEqual(track1event1? .startTimecode.stringValue, "01:00:02:00")
		XCTAssertEqual(track1event2? .startTimecode.stringValue, "01:00:04:00")
		XCTAssertEqual(track1event3? .startTimecode.stringValue, "01:00:09:18")
		XCTAssertEqual(track1event4? .startTimecode.stringValue, "01:00:11:06")
		XCTAssertEqual(track1event5? .startTimecode.stringValue, "01:00:16:05")
		XCTAssertEqual(track1event6? .startTimecode.stringValue, "01:00:17:29")
		#warning("these tests are correct but will fail until I work on the code that calculates timecodes for musical mode track events when there is a tempo track with multiple tempo change events")
		//XCTAssertEqual(track1event7? .startTimecode.stringValue, "01:00:26:02")
		//XCTAssertEqual(track1event8? .startTimecode.stringValue, "01:00:29:09")
		//XCTAssertEqual(track1event9? .startTimecode.stringValue, "01:00:31:24")
		//XCTAssertEqual(track1event10?.startTimecode.stringValue, "01:50:25:07")
		
		// track 2 - linear mode
		
		let track2 = trackArchive.tracks?[1] as? Cubase.TrackArchive.MarkerTrack
		XCTAssertNotNil(track2)
		
		let track2event1  = track2?.events[safe: 0] as? Cubase.TrackArchive.Marker
		let track2event2  = track2?.events[safe: 1] as? Cubase.TrackArchive.CycleMarker
		let track2event3  = track2?.events[safe: 2] as? Cubase.TrackArchive.Marker
		let track2event4  = track2?.events[safe: 3] as? Cubase.TrackArchive.CycleMarker
		let track2event5  = track2?.events[safe: 4] as? Cubase.TrackArchive.Marker
		let track2event6  = track2?.events[safe: 5] as? Cubase.TrackArchive.CycleMarker
		let track2event7  = track2?.events[safe: 6] as? Cubase.TrackArchive.Marker
		let track2event8  = track2?.events[safe: 7] as? Cubase.TrackArchive.Marker
		let track2event9  = track2?.events[safe: 8] as? Cubase.TrackArchive.Marker
		let track2event10 = track2?.events[safe: 9] as? Cubase.TrackArchive.Marker
		
		XCTAssertEqual(track2event1? .startTimecode.stringValue, "01:00:02:00")
		XCTAssertEqual(track2event2? .startTimecode.stringValue, "01:00:04:00")
		XCTAssertEqual(track2event3? .startTimecode.stringValue, "01:00:09:18")
		XCTAssertEqual(track2event4? .startTimecode.stringValue, "01:00:11:06")
		XCTAssertEqual(track2event5? .startTimecode.stringValue, "01:00:16:05")
		XCTAssertEqual(track2event6? .startTimecode.stringValue, "01:00:17:29")
		XCTAssertEqual(track2event7? .startTimecode.stringValue, "01:00:26:02")
		XCTAssertEqual(track2event8? .startTimecode.stringValue, "01:00:29:09")
		XCTAssertEqual(track2event9? .startTimecode.stringValue, "01:00:31:24")
		XCTAssertEqual(track2event10?.startTimecode.stringValue, "01:50:25:07")
		
	}
	
	func testRoundingTest() {
		
		guard let data = XML_RoundingTest.toData()
			else { XCTFail() ; return }
		
		guard let trackArchive = Cubase.TrackArchive(fromData: data)
			else { XCTFail() ; return }
		
		// ---- tracks ----
		
		XCTAssertEqual(trackArchive.tracks?.count, 2)
		
		// track 1 - musical mode
		
		let track1 = trackArchive.tracks?[0] as? Cubase.TrackArchive.MarkerTrack
		XCTAssertNotNil(track1)
		XCTAssertEqual(track1?.events.count, 4)
		
		var track1event1 = track1?.events[safe: 0] as? Cubase.TrackArchive.Marker
		var track1event2 = track1?.events[safe: 1] as? Cubase.TrackArchive.Marker
		var track1event3 = track1?.events[safe: 2] as? Cubase.TrackArchive.Marker
		var track1event4 = track1?.events[safe: 3] as? Cubase.TrackArchive.Marker
		
		track1event1?.startTimecode.displaySubFrames = true
		track1event2?.startTimecode.displaySubFrames = true
		track1event3?.startTimecode.displaySubFrames = true
		track1event4?.startTimecode.displaySubFrames = true
		
		XCTAssertEqual(track1event1?.startTimecode.stringValue, "01:00:01:29.00") // as displayed in Cubase
		XCTAssertEqual(track1event2?.startTimecode.stringValue, "01:00:01:29.78") // as displayed in Cubase
		XCTAssertEqual(track1event3?.startTimecode.stringValue, "01:00:01:29.79") // as displayed in Cubase
		XCTAssertEqual(track1event4?.startTimecode.stringValue, "01:00:02:00.00") // as displayed in Cubase
		
		// track 2 - linear mode
		
		let track2 = trackArchive.tracks?[1] as? Cubase.TrackArchive.MarkerTrack
		XCTAssertNotNil(track2)
		XCTAssertEqual(track2?.events.count, 4)
		
		var track2event1 = track2?.events[safe: 0] as? Cubase.TrackArchive.Marker
		var track2event2 = track2?.events[safe: 1] as? Cubase.TrackArchive.Marker
		var track2event3 = track2?.events[safe: 2] as? Cubase.TrackArchive.Marker
		var track2event4 = track2?.events[safe: 3] as? Cubase.TrackArchive.Marker
		
		track2event1?.startTimecode.displaySubFrames = true
		track2event2?.startTimecode.displaySubFrames = true
		track2event3?.startTimecode.displaySubFrames = true
		track2event4?.startTimecode.displaySubFrames = true
		
		XCTAssertEqual(track2event1?.startTimecode.stringValue, "01:00:01:29.00") // as displayed in Cubase
		XCTAssertEqual(track2event2?.startTimecode.stringValue, "01:00:01:29.78") // as displayed in Cubase
		XCTAssertEqual(track2event3?.startTimecode.stringValue, "01:00:01:29.79") // as displayed in Cubase
		XCTAssertEqual(track2event4?.startTimecode.stringValue, "01:00:02:00.00") // as displayed in Cubase
		
	}
	
}

class DAWFileKit_Cubase_Helper_Tests: XCTestCase {
	
	override func setUp() { }
	override func tearDown() { }
	
	func testCollection_XMLNode_FilterAttribute() {
		
		// prep
		
		let nodes = [try! XMLElement(xmlString: "<obj class='classA' name='name1'/>"),
					 try! XMLElement(xmlString: "<obj class='classA' name='name2'/>"),
					 try! XMLElement(xmlString: "<obj class='classB' name='name3'/>"),
					 try! XMLElement(xmlString: "<obj class='classB' name='name4'/>")]
		
		// test
		
		var filtered = nodes.filter(nameAttribute: "name2")
		XCTAssertEqual(filtered[0], nodes[1])
		
		filtered = nodes.filter(classAttribute: "classA")
		XCTAssertEqual(filtered, [nodes[0], nodes[1]])
		
	}
	
}
