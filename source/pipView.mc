import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

using Toybox.Time.Gregorian as Date;

using Toybox.ActivityMonitor as Mon;

class pipView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        setTimeDisplay();
        setHeartrateDisplay();
        setStepCountDisplay();
        setDateDisplay();

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    private function setDateDisplay() {        
    	var now = Time.now();
	    var date = Date.info(now, Time.FORMAT_MEDIUM);
	    var dateString = Lang.format("$1$ $2$, $3$", [date.month, date.day, date.year]);
	    var view = View.findDrawableById("DateLabel") as Text;      
	    view.setText(dateString);	    	
    }

    private function setTimeDisplay() {
        // Get and show the current time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var view = View.findDrawableById("TimeLabel") as Text;
        view.setText(timeString);
    }

    private function setStepCountDisplay() {
    	var stepCount = Mon.getInfo().steps.toString();		
	    var view = View.findDrawableById("StepLabel") as Text;      
	    view.setText(stepCount + " steps");
    }

    private function setHeartrateDisplay() {
    	var heartRate = "";
    	
    	if(Mon has :INVALID_HR_SAMPLE) {
    		heartRate = retrieveHeartrateText();
    	}
    	else {
    		heartRate = "";
    	}
    	
        var view = View.findDrawableById("HeartrateLabel") as Text;  
	    view.setText(heartRate);
    }
    
    private function retrieveHeartrateText() {
    	var heartrateIterator = ActivityMonitor.getHeartRateHistory(null, false);
	    var currentHeartrate = heartrateIterator.next().heartRate;

	    if(currentHeartrate == Mon.INVALID_HR_SAMPLE) {
		    return "";
	    }		

	    return currentHeartrate.format("%d");
    }   

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
