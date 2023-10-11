(
var getClassFile = { |class|
	var file, string;
	file = File(
		class.filenameSymbol.asString,
		"r");
	string = file.readAllString;
	file.close;
	string
};

var getClassDefinition = { |class, verbose=false|
	var file = getClassFile.value(class);
	var matchString = class.asString;
	var position;
	var classDef = "";
	var openedBrackets = 0;

	matchString = matchString ++ " : ";
	matchString = matchString ++ class.superclass.asString;

	position = file.find(matchString);
	// Try orphan Class
	if(position.isNil) {
		matchString = class.asString ++ " {";
		position = file.find(matchString); };
	// Try adding [slot]
	if(position.isNil) {
		[
			"[slot]",
			"[int8]", "[int16]", "[int32]",
			"[float]", "[double]", "[symbol]"
		].do({ |symbol|
			if(position.isNil) {
				matchString = class.asString;
				matchString = matchString ++ symbol;
				matchString = matchString = " : ";
				matchString = matchString ++ class.superclass.asString;
				position = file.find(matchString); };
		});
	};
	// fix : LIDGui
	if(position.isNil) {
		matchString = class.asString ++ "{";
		position = file.find(matchString);
	};

	// fix : MultiTap / PMOsc / PatternConductor / SoundIn
	if(position.isNil) {
		matchString = class.asString ++ "  {";
		position = file.find(matchString);
	};

	if(position.notNil) {
		while { openedBrackets == 0 } {
			var char = file[position];
			classDef = classDef ++ char;
			if(char == ${)
			{ openedBrackets = 1 };
			position = position + 1;
		};
		while { openedBrackets > 0 } {
			var char = file[position];
			classDef = classDef ++ char;
			if(char == ${) { openedBrackets = openedBrackets + 1 };
			if(char == $}) { openedBrackets = openedBrackets - 1 };
			position = position + 1;
		};
	} {
		if(verbose)
		{ ("Unable to scan class " ++ class.name.asString).postln; }
	};
	// Return
	classDef
};

Class.allClasses.do({ |class|
	if(class.name.asString.beginsWith("Meta_").not) {
		var classDef = getClassDefinition.value(class, true);
		//classDef.postln;
		//class.name.postln;
		//"".postln;
	};
});
)