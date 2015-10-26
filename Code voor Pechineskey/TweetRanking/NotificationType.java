package nl.ramondevaan.tweetranking;

public enum NotificationType {
    BRANDWEER, POLITIE, AMBULANCE, NONE;

    public static NotificationType parseNotificationType(String s) {
        if(s.equalsIgnoreCase("ambulance")) {
            return AMBULANCE;
        }
        if(s.equalsIgnoreCase("brandweer")) {
            return BRANDWEER;
        }
        if(s.equalsIgnoreCase("politie")) {
            return POLITIE;
        }

        return NONE;
    }
}
