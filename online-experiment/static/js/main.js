// Initalize psiturk object: gives us variable *condition* from the server
var psiTurk = new PsiTurk(uniqueId, adServerLoc, mode);

// All pages to be loaded
var pages = [
	"instructions/instruction.html",
	"item.html",
    "switching.html",
    "postquestionnaire.html"
];

var instructionPages = [
	"instructions/instruction.html",
];

psiTurk.preloadPages(pages);

// Task object to keep track of the current phase
var currentview;

// RUN TASK
$(window).load(function(){
    psiTurk.doInstructions(
    	instructionPages, // list of instruction pages
    	function() { currentview = new Experiment(); } // after instructions
    );
});
