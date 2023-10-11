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

var classMentionnedInFile = { |scannedClass, otherClass|
	var isMentionned;
	var file = getClassFile.value(otherClass);
	scannedClass = scannedClass.asString;
	isMentionned = scannedClass.matchRegexp(file);
	isMentionned
};

var findDependantsInLibrary = { |class|
	var dependants = List(0);
	Class.allClasses.do({ |otherClass|
		if(class != otherClass) {
			if(classMentionnedInFile.value(class, otherClass))
			{ dependants.add(otherClass.asString) };
		};
	});

	"----------------".postln;
	"Class : ".post;
	class.asString.postln;
	"N° of dependent classes found : ".post;
	dependants.size.postln;
	"".postln;
	dependants.do({ |dep| dep.postln; });
};

findDependantsInLibrary.value(SinOsc);
""
)