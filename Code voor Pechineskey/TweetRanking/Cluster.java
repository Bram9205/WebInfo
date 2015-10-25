package nl.ramondevaan.tweetranking;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class Cluster {
    private int clusterId;
    private P2000[] notifications;
    private Set<NotificationType> notificationTypes;
    private String[] query;

    public Cluster(P2000[] notifications) {
        if(notifications == null || notifications.length == 0) {
            throw new IllegalArgumentException("Can't cluster an empty set of notifications.");
        }
        this.clusterId = notifications[0].getCluster();
        this.notifications = notifications;
        notificationTypes = new HashSet<>();
        Set<String> q = new HashSet<>();
        for(P2000 p : notifications) {
            notificationTypes.add(p.getNotificationType());
            q.addAll(Arrays.asList(p.getText().split("\\s+")));
        }
        query = q.toArray(new String[q.size()]);
    }

    public int getClusterId() {
        return clusterId;
    }

    public P2000[] getNotifications() {
        return notifications;
    }

    public String[] getQuery() {
        return query;
    }

    public boolean allNone() {
        for(NotificationType n : notificationTypes) {
            if(n != NotificationType.NONE) {
                return false;
            }
        }

        return true;
    }

    @Override
    public boolean equals(Object other) {
        if (other == null) return false;
        if (other == this) return true;
        if (!(other instanceof Cluster)) return false;
        return ((Cluster) other).getClusterId() == this.getClusterId();
    }
}
