package nl.ramondevaan.tweetranking;

import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;

public class P2000 {
    private final static String ID_COLUMN_NAME = "id";
    private final static String DATE_COLUMN_NAME = "date";
    private final static String TIME_COLUMN_NAME = "time";
    private final static String TYPE_COLUMN_NAME = "type";
    private final static String REGION_COLUMN_NAME = "region";
    private final static String POSTAL_COLUMN_NAME = "postal_code";
    private final static String TOWN_COLUMN_NAME = "town";
    private final static String CONTENT_COLUMN_NAME = "content";
    public final static String CLUSTER_COLUMN_NAME = "cluster";
    private final static String COORDS_COLUMN_NAME = "coordinates";

    private int id;
    private long date;
    private NotificationType notificationType;
    private String region;
    private String postal;
    private String town;
    private String text;
    private int cluster;
    private String coords;

    public P2000(int id, long date, NotificationType notificationType, String region, String postal, String town, String text, int cluster, String coords) {
        this.id = id;
        this.date = date;
        this.notificationType = notificationType;
        this.region = region.toLowerCase();
        this.postal = postal;
        this.town = town.toLowerCase();
        this.text = text.toLowerCase();
        this.cluster = cluster == 0 ? id : cluster;
        this.coords = coords;
    }

    public int getId() {
        return id;
    }

    public long getDate() {
        return date;
    }

    public NotificationType getNotificationType() {
        return notificationType;
    }

    public String getRegion() {
        return region;
    }

    public String getPostal() {
        return postal;
    }

    public String getTown() {
        return town;
    }

    public String getText() {
        return text;
    }

    public int getCluster() {
        return cluster;
    }

    public String getCoordinates() {
        return coords;
    }

    public static P2000[] getP2000sFromResultSet(ResultSet rs) {
        try {
            if(rs.first()) {
                List<P2000> P2000s = new ArrayList<>();

                int[] ind = getIndices(rs);

                P2000s.add(getP2000(rs, ind));

                while(rs.next()) {
                    P2000s.add(getP2000(rs, ind));
                }

                return P2000s.toArray(new P2000[P2000s.size()]);
            }
        } catch (SQLException | ParseException e) {
            //Do nothing
        }

        return new P2000[0];
    }

    private static P2000 getP2000(ResultSet rs, int[] ind) throws SQLException, ParseException {
        return new P2000(rs.getInt(ind[0]),
                parseDate(rs.getDate(ind[1]), rs.getTime(ind[2])),
                NotificationType.parseNotificationType(rs.getString(ind[3])),
                rs.getString(ind[4]),
                rs.getString(ind[5]),
                rs.getString(ind[6]),
                rs.getString(ind[7]),
                rs.getInt(ind[8]),
                rs.getString(ind[9]));
    }

    private static int[] getIndices(ResultSet rs) throws SQLException {
        return new int[]{
                rs.findColumn(ID_COLUMN_NAME),
                rs.findColumn(DATE_COLUMN_NAME),
                rs.findColumn(TIME_COLUMN_NAME),
                rs.findColumn(TYPE_COLUMN_NAME),
                rs.findColumn(REGION_COLUMN_NAME),
                rs.findColumn(POSTAL_COLUMN_NAME),
                rs.findColumn(TOWN_COLUMN_NAME),
                rs.findColumn(CONTENT_COLUMN_NAME),
                rs.findColumn(CLUSTER_COLUMN_NAME),
                rs.findColumn(COORDS_COLUMN_NAME)
        };
    }

    private static long parseDate(Date date, Time time) throws ParseException {
        return date.getTime() + time.getTime();
    }

    @Override
    public boolean equals(Object other) {
        if (other == null) return false;
        if (other == this) return true;
        if (!(other instanceof P2000)) return false;
        return ((P2000) other).getId() == this.getId();
    }

    @Override
    public String toString() {
        return id + " - " + date + " - " + notificationType.toString();
    }
}
