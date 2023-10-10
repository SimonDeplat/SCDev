(
var classDict = ();

var getClassFile = { |class|
	var file, string;
	file = File(
		class.filenameSymbol.asString,
		"r");
	string = file.readAllString;
	file.close;
	string
};

var codeToWords = { |string|
	// Didn't remove comments
	// Remove code symbols
	"(){}[]^.;:\"|,<>*+-/=!%".do({ |char|
		string = string.replace(char, " ");
	});
	// Remove special chars
	[Char.nl, Char.tab].do({ |char|
		string = string.replace(char, " "); });
	// Remove multiple spaces
	while { "  ".matchRegexp(string); }
	{ string = string.replace("  ", " "); };
	string = string.split(Char.space);
	// Remove empty strings
	string = string.select({ |word| (word != "") });
	// Remove numbers, words, primitives
	string = string.select({ |word|
		(word.asInteger == 0)
		&&
		(word.beginsWith("_").not)
		&&
		(word[0].isUpper);
	});
	// Return
	string
};

var sortByOccurences = { |dict|
	var sortedList = List(0);
	dict = dict.asSortedArray;
	sortedList.add(dict.pop);
	//dict.postln;
	dict.do({ |array|
		var index = 0;
		sortedList.do({ |storedArray|
			if(array[1] > storedArray[1])
			{ index = index + 1; };
		});
		sortedList.insert(index, array);
	});
	sortedList = sortedList.reverse;
	sortedList
};

var postResults = { |class, classes, modString = ""|
	"----------------".postln;
	modString.postln;
	"Class : ".post;
	class.asString.postln;
	"N° of classes dependencies found : ".post;
	classes.size.postln;
	"".postln;
	classes.do({ |array|
		array[0].post;
		" : ".post;
		array[1].post;
		" occurence(s)".postln;
	});
};

var findClassNamesInClassCode = { |class, verbose=true|
	var classes = ();
	var string = getClassFile.value(class);
	// Convert to words
	string = codeToWords.value(string);
	// Check if the word is acually a class
	string = string.select({ |word|
		var initial = word[0].asSymbol;
		var isClass = classDict.includesKey(initial);
		if(isClass)
		{ isClass = classDict[initial].includesEqual(word) };
		isClass
	});
	// Remove self references
	string = string.select({ |word|
		word != class.asString;	});
	// Add occurences
	string.do({ |word|
		if(classes.includesKey(word.asSymbol).not)
		{ classes[word.asSymbol] = 0; };
		classes[word.asSymbol] = classes[word.asSymbol] + 1; });
	// End
	classes = sortByOccurences.value(classes);
	if(verbose) { postResults.value(class, classes, "Scanning Class only"); };
	classes
};

var findClassNamesInClassTreeCode = { |class, verbose=true|
	var baseValues = findClassNamesInClassCode.value(class, false);
	var classes = ();
	// Convert array back to dict
	baseValues.do({ |array|
		classes[array[0].asSymbol] = array[1]; });
	// Iterate through parents
	class.superclasses.do({ |parentClass|
		var newDependencies = findClassNamesInClassCode.value(
			parentClass, false);
		newDependencies.do({ |array|
			if(classes.includesKey(array[0].asSymbol).not)
			{ classes[array[0].asSymbol] = 0 };
			classes[array[0].asSymbol] = classes[array[0].asSymbol] + array[1];
		});
	});
	// End
	classes = sortByOccurences.value(classes);
	if(verbose) { postResults.value(class, classes, "Scanning Class Tree"); };
};

var addDependenciesTo = { |dict, newArray|
	newArray.do({ |pair|
		if(dict.includesKey(pair[0].asSymbol).not)
		{ dict[pair[0].asSymbol] = 0 };
		dict[pair[0].asSymbol] = dict[pair[0].asSymbol] + pair[1];
	});
	dict
};

var findAllAccessibleClassNames = { |class|
	var scannedClasses = List(0);
	var queuedClasses = List(0);
	var classes = ();
	// What do we have left to scan ?
	queuedClasses.add(class.asString);
	// While we didn't scan every queued class
	while { queuedClasses.size > 0 }
	{
		// Get Class by name
		var classIndex = Class.allClasses.detectIndex({ |class|
			class.asString == queuedClasses[0]; });
		var newClasses;
		// Open first queued class
		newClasses = findClassNamesInClassCode.value(
			Class.allClasses[classIndex], false);
		// If not a dead end
		if(newClasses != List().add(nil)) {
			// Update dependencies
			classes = addDependenciesTo.value(classes, newClasses);
			newClasses.do({ |array|
				var classAsString = array[0].asString;
				if(scannedClasses.includesEqual(classAsString).not) {
					if(queuedClasses.includesEqual(classAsString).not) {
						queuedClasses.add(classAsString);
					};
				};
			});
		};
		// Swap from queued to scanned
		scannedClasses.add(queuedClasses[0]);
		queuedClasses.removeAt(0);
	};
	// End
	classes = sortByOccurences.value(classes);
	postResults.value(class, classes, "Scanning All Related Classes");
};

Class.allClasses.do({ |class|
	var firstLetter = class.asString[0].asSymbol;
	if(classDict.includesKey(firstLetter).not)
	{ classDict[firstLetter] = List(0); };
	classDict[firstLetter].add(class.asString);
});

// Class file dependencies detection
findClassNamesInClassCode.value(Button);
"".postln;
// Class Tree dependencies detection
findClassNamesInClassTreeCode.value(Button);
"".postln;
// All accessible class names.
// Takes a while to compute
//findAllAccessibleClassNames.value(Object);
""
)