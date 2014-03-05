package flash.events;


@:enum abstract EventPhase(Int) {
	
	var CAPTURING_PHASE = 0;
	var AT_TARGET = 1;
	var BUBBLING_PHASE = 2;
	
}