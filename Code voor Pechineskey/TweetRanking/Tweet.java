package nl.ramondevaan.tweetranking;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

public class Tweet {
    private final static String ID_COLUMN_NAME = "id";
    private final static String TEXT_COLUMN_NAME = "text";
    private final static String TOKENIZED_TEXT_COLUMN_NAME = "tokonized_text";
    private final static String DATE_COLUMN_NAME = "datum";
    private final static String LOCATION_COLUMN_NAME = "locatie";
    private final static String LABEL_COLUMN_NAME = "label_tweet";

    private final static SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("EEE MMM dd HH:mm:ss Z yyyy", Locale.US);

    private int id;
    private String text;
    private String tokenized_text;
    private long date;
    private String location;
    private String label;
    private Map<String, Integer> termFrequency;

    public Tweet(int id, String text, String tokenized_text, long date, String location, String label) {
        this.id = id;
        this.text = text;
        this.tokenized_text = tokenized_text;
        this.date = date;
        this.location = location.toLowerCase();
        this.label = label;
        termFrequency = new HashMap<>();

        for(String word : tokenized_text.split("\\s+")) {
            termFrequency.put(word, termFrequency.getOrDefault(word, 0) + 1);
        }
    }

    public int getId() {
        return id;
    }

    public String getText() {
        return text;
    }

    public String getTokenized_text() {
        return tokenized_text;
    }

    public long getDate() {
        return date;
    }

    public String getLocation() {
        return location;
    }

    public String getLabel() {
        return label;
    }

    public Map<String, Integer> getTermFrequencyMap() {
        return termFrequency;
    }

    public int termFrequency(String word) {
        return termFrequency.getOrDefault(word, 0);
    }

    public static TweetCollection getTweetsFromResultSet(ResultSet rs) {
        TweetCollection tweets = new TweetCollection();

        try {
            if(rs.first()) {
                int[] ind = getIndices(rs);

                tweets.add(getTweet(rs, ind));

                while(rs.next()) {
                    tweets.add(getTweet(rs, ind));
                }

                return tweets;
            }
        } catch (SQLException | ParseException e) {
            //Do nothing
        }

        return tweets;
    }

    private static Tweet getTweet(ResultSet rs, int[] ind) throws SQLException, ParseException {
        return new Tweet(rs.getInt(ind[0]),
                rs.getString(ind[1]),
                rs.getString(ind[2]),
                parseDate(rs.getString(ind[3])),
                rs.getString(ind[4]),
                rs.getString(ind[5]));
    }

    private static int[] getIndices(ResultSet rs) throws SQLException {
        return new int[]{
            rs.findColumn(ID_COLUMN_NAME),
            rs.findColumn(TEXT_COLUMN_NAME),
            rs.findColumn(TOKENIZED_TEXT_COLUMN_NAME),
            rs.findColumn(DATE_COLUMN_NAME),
            rs.findColumn(LOCATION_COLUMN_NAME),
            rs.findColumn(LABEL_COLUMN_NAME)
        };
    }

    private static long parseDate(String date) throws ParseException {
        return DATE_FORMAT.parse(date).getTime();
    }

    @Override
    public boolean equals(Object other) {
        if (other == null) return false;
        if (other == this) return true;
        if (!(other instanceof Tweet)) return false;
        return ((Tweet) other).getId() == this.getId();
    }

    @Override
    public String toString() {
        return "{" + getId() + ", " + getText() + ", " + getTokenized_text() + ", " + getDate() + ", " + getLocation() + ", " + getLabel() + "}";
    }
}
