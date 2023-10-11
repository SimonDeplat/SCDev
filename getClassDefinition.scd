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

var getClassDefinition = { |class|
	var file = getClassFile.value(class);
	var matchString = class.asString;
	var position;
	var classDef = "";
	var openedBrackets = 0;
	if((class === Object).not) {
		matchString = matchString ++ " : ";
		matchString = matchString ++ class.superclass.asString;
		position = file.find(matchString);
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
		"This function does not work on Object".postln;
	};
	classDef
};

var classDef = getClassDefinition.value(View);
classDef.postln;
""
)