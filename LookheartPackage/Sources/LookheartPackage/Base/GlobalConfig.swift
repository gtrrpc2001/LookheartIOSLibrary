import Foundation


public let ECG_MAX_ARRAY = 500
public let ECG_DATA_MAX = 140

public let PrevDateKey = "prevDate"
public let PrevHourKey = "prevHour"

public let ARR_TAG = 1, ARR_STATE = "arr"
public let EMERGENCY_TAG = 2
public let NONCONTACT_TAG = 3
public let MYO_TAG = 4
public let FAST_ARR_TAG = 5, FAST_ARR_STATE = "fast"
public let SLOW_ARR_TAG = 6, SLOW_ARR_STATE = "slow"
public let HEAVY_ARR_TAG = 7, HEAVY_ARR_STATE = "irregular"


public var propProfil: UserProfileManager {
    get {
        return UserProfileManager.shared
    }
}

public var propEmail : String {
    get {
        return UserProfileManager.shared.email
    }
}

public var propCurrentTime : String {
    get {
        return MyDateTime.shared.getCurrentDateTime(.TIME)
    }
}


public var propCurrentDate : String {
    get {
        return MyDateTime.shared.getCurrentDateTime(.DATE)
    }
}


public var propCurrentDateTime: String {
    get {
        return MyDateTime.shared.getCurrentDateTime(.DATETIME)
    }
}

public var propCurrentHour: String {
    get {
        return MyDateTime.shared.getSplitDateTime(.TIME)[0]
    }
}

public var propTimeZone: String {
    get {
        return MyDateTime.shared.getTimeZone()
    }
}


public var propAlert: MyAlert {
    get {
        return MyAlert.shared
    }
}


public var propCreateUI: CreateUI {
    get {
        return CreateUI.shared
    }
}

public var getAppVersion: String? {
    get {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
