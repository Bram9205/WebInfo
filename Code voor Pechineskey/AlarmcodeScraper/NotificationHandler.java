package nl.ramondevaan.webinf;

public interface NotificationHandler {
    public void handleNotification(String id, int region, String location, String description);
}
