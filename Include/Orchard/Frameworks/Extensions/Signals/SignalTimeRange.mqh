/*
 	SignalTimeRange.mqh
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/
 
// Next line assumes this file is located in .../Frameworks/Extensions/someFolder 
#include	"../../Framework.mqh"

class CSignalTimeRange : public CSignalBase {

private:

protected:	// member variables

//	Place any required member variables here
	bool	mCheckInside;
	int	mStartHour;
	int	mStartMinute;
	int	mStartTime;
	int	mEndHour;
	int	mEndMinute;
	int	mEndTime;
	
protected:	//	functions

	bool	InsideRange();
	
public:	// constructors

	//	Add any required constructor arguments
	//	e.g. CSignalXYZ(int periods, double multiplier)
	CSignalTimeRange(int startHour, int startMinute, int endHour, int endMinute, bool checkInside=true)
								:	CSignalBase()
								{	Init(startHour, startMinute, endHour, endMinute, checkInside);	}
	// Same constructor with symbol and timeframe added
	CSignalTimeRange(string symbol, ENUM_TIMEFRAMES timeframe,
								int startHour, int startMinute, int endHour, int endMinute, bool checkInside=true)
								:	CSignalBase(symbol, timeframe)
								{	Init(startHour, startMinute, endHour, endMinute, checkInside);	}
	~CSignalTimeRange()	{	}
	
	//	Include all arguments to match the constructor
	int			Init(int startHour, int startMinute, int endHour, int endMinute, bool checkInside);

public:

	//	Add this line to override the same function from the parent class
	virtual void								UpdateSignal();

};

int		CSignalTimeRange::Init(int startHour, int startMinute, int endHour, int endMinute, bool checkInside) {

	//	Checks if init has been set to fail by any parent class already
	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());

	//	Assign variables and do any other initialisation here	
	if (!(0<=startHour && startHour<=23))
		return(InitError("Start hour must be from 0-23", INIT_FAILED));
	if (!(0<=startMinute && startMinute<=59))
		return(InitError("Start minute must be from 0-59", INIT_FAILED));
	if (!(0<=endHour && endHour<=23))
		return(InitError("End hour must be from 0-23", INIT_FAILED));
	if (!(0<=endMinute && endMinute<=59))
		return(InitError("End minute must be from 0-59", INIT_FAILED));

	mCheckInside	=	checkInside;
	
	mStartHour		=	startHour;
	mStartMinute	=	startMinute;
	mEndHour			=	endHour;
	mEndMinute		=	endMinute;

	mStartTime		=	startHour*60+startMinute;
	mEndTime			=	endHour*60+endMinute;
		
	return(INIT_SUCCEEDED);
	
}

void		CSignalTimeRange::UpdateSignal() {

	//	For this signal set both entry and exit if inside the time range
	//	If not needed for the exit signal then just leave it from the expert
	//		Makes sense in the example

	bool	insideRange	=	InsideRange();
	if (!mCheckInside)	insideRange	=	!insideRange;	//	just reverse it

	if (insideRange) {
		mEntrySignal	=	OFX_SIGNAL_BOTH;
	} else {
		mEntrySignal	=	OFX_SIGNAL_NONE;	//	Default
	}
	mExitSignal	=	mEntrySignal;
				 
	return;
	
}

bool	CSignalTimeRange::InsideRange() {

	if (mStartTime==mEndTime) {
		return(true);
	}
	
	MqlDateTime	mqlNow;
	TimeCurrent(mqlNow);
	int	now	=	mqlNow.hour*60+mqlNow.min;

	return(	
				(mStartTime<mEndTime && mStartTime<=now && now<=mEndTime)			// common
				|| (mEndTime<mStartTime && (now>=mStartTime || now<=mEndTime) )	//	less common
			);
}

	
