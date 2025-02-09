import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

using Toybox.Position;

using Toybox.Time.Gregorian as Date;
using Toybox.ActivityMonitor as Mon;
using Toybox.Weather as Climate;
using Toybox.System as Sys;


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
        setSunDisplay();
        setDateDisplay();
        setTemperatureDisplay();
        setBatteryDisplay();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        setTimeDisplay();
        setHeartrateDisplay();
        setStepCountDisplay();
        setBluetoothDisplay();

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

    private function setBatteryDisplay() {
        var battery = Sys.getSystemStats().battery;
        var batStr = Lang.format( "$1$", [ battery.format( "%2d" ) ] );
        var view = View.findDrawableById("BatteryLabel") as Text;
        view.setText(batStr);
    }

    private function setBluetoothDisplay() {
        var icon = View.findDrawableById("BluetoothIcon");
        var mySettings = System.getDeviceSettings();
        if (mySettings.phoneConnected == true) {
            icon.setVisible(true);
        } else {
            icon.setVisible(false);
        }
    }

    private function setStepCountDisplay() {
    	var stepCount = Mon.getInfo().steps.toString();		
	    var view = View.findDrawableById("StepLabel") as Text;      
	    view.setText(stepCount + " steps");
    }

    private function setSunDisplay() {
        var location = Position.getInfo().position;
        var now = Time.now();

        // Set sunrise label
        var sunriseTime = Climate.getSunrise(location, now);
        var view = View.findDrawableById("SunriseLabel") as Text;
        if (sunriseTime != null) {
            var gregSunriseTime = Date.info(sunriseTime, Time.FORMAT_MEDIUM);
            var sunriseTimeString = Lang.format("$1$:$2$", [gregSunriseTime.hour, gregSunriseTime.min.format("%02d")]);

            view.setText(sunriseTimeString);
        } else {
            view.setText("-");
        }

        // Set sunset label
        var sunsetTime = Climate.getSunset(location, now);
        view = View.findDrawableById("SunsetLabel") as Text;
        if (sunsetTime != null) {
            var gregSunsetTime = Date.info(sunsetTime, Time.FORMAT_MEDIUM);
            var sunsetTimeString = Lang.format("$1$:$2$", [gregSunsetTime.hour, gregSunsetTime.min.format("%02d")]);

            view.setText(sunsetTimeString);
        } else {
            view.setText("-");
        }

        
    }

    private function setTemperatureDisplay() {
        var celsiusTemp = Climate.getCurrentConditions().temperature;
        // TODO: Allow option for celsius temperature
        var temp = ((celsiusTemp * 1.8) + 32).toNumber() as Text;
        var view = View.findDrawableById("TemperatureLabel") as Text;
        view.setText("Temp: " + temp + "°F");

        var celsiusHighTemp = Climate.getCurrentConditions().highTemperature;
        var highTemp = ((celsiusHighTemp * 1.8) + 32).toNumber() as Text;

        var celsiusLowTemp = Climate.getCurrentConditions().lowTemperature;
        var lowTemp = ((celsiusLowTemp * 1.8) + 32).toNumber() as Text;
        
        view = View.findDrawableById("HighLowTempLabel") as Text;
        view.setText(highTemp + "/" + lowTemp);
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
