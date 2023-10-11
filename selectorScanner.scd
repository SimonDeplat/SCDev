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

// This needs more work, for example it's reading comments
// so there will be collisions with words such as "new", "as", etc.
var selectorMentionnedInFile = { |selector, class|
	var isMentionned;
	var file = getClassFile.value(class);
	isMentionned = selector.matchRegexp(file);
	isMentionned
};

var findSelectorInLibrary = { |selector|
	var dependants = List(0);
	Class.allClasses.do({ |otherClass|
		if(selectorMentionnedInFile.value(
			selector, otherClass))
		{ dependants.add(otherClass.asString) };
	});

	"----------------".postln;
	"Selector : ".post;
	selector.asString.postln;
	"N° of dependent classes found : ".post;
	dependants.size.postln;
	"".postln;
	dependants.do({ |dep| dep.postln; });
};

var findClassSelectorsInLibrary = { |class|
	var selectors = List(0);
	class.methods.do({ |method|
		method = method.name.asString;
		if(method.endsWith("_"))
		{ method = method.replace("_", ""); };
		if(selectors.includesEqual(method).not)
		{ selectors.add(method); };
	});

	"----------------".postln;
	"Class : ".post;
	class.asString.postln;
	"Scanning Library for methods calls".postln;
	"Results might be polymorphism collisions".postln;
	"".postln;

	selectors.do({ |selector|
		findSelectorInLibrary.value(selector);
		"".postln;
	});
};

// Find every class mentionning a selector (method name) :
// findSelectorInLibrary.value("asString");

// For every method of a class, find every class
// in the library that includes this method's selector
// in it's code :
findClassSelectorsInLibrary.value(Button);

""
)