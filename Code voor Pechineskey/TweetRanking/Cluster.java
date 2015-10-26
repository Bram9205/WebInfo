package nl.ramondevaan.tweetranking;

import java.util.HashSet;
import java.util.Set;

public class Cluster {
    private int clusterId;
    private P2000[] notifications;
    private Set<NotificationType> notificationTypes;
    private String[] query;
    private String[] labels;
    private String[] subLabels;
    private long earliestTime;

    public Cluster(P2000[] notifications) {
        if(notifications == null || notifications.length == 0) {
            throw new IllegalArgumentException("Can't cluster an empty set of notifications.");
        }
        this.clusterId = notifications[0].getCluster();
        this.notifications = notifications;
        earliestTime = Long.MAX_VALUE;
        notificationTypes = new HashSet<>();
        Set<String> q = new HashSet<>();
        Set<String> ls = new HashSet<>();
        Set<String> subls = new HashSet<>();
        for(P2000 p : notifications) {
            notificationTypes.add(p.getNotificationType());
            for (String s : p.getText().split("\\s+")) {
                q.add(s.toLowerCase());
            }
            earliestTime = Math.min(earliestTime, p.getDate());
            ls.add(p.getLabel().toLowerCase());
            subls.add(p.getLabel().toLowerCase());
        }
        query = q.toArray(new String[q.size()]);
        labels = ls.toArray(new String[ls.size()]);
        subLabels = subls.toArray(new String[subls.size()]);
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

    public String[] getLabels() {
        return labels;
    }

    public String[] getSubLabels() {
        return subLabels;
    }

    public Set<NotificationType> getNotificationTypes() {
        return notificationTypes;
    }

    public long getEarliestTime() {
        return earliestTime;
    }

    @Override
    public boolean equals(Object other) {
        if (other == null) return false;
        if (other == this) return true;
        if (!(other instanceof Cluster)) return false;
        return ((Cluster) other).getClusterId() == this.getClusterId();
    }
}
