package nl.ramondevaan.tweetranking;

import java.sql.*;
import java.text.ParseException;
import java.util.*;

public class Main {
    private final static String TWEET_TABLE_NAME = "tweets";
    private final static String TWEET_LABELS_TABLE_NAME = "labels_tweets";
    private final static String P2000_TABLE_NAME = "notifications";
    private final static String P2000_LABEL_TABLE_NAME = "labels";
    private final static String ASSOC_TABLE_NAME = "p2000_tweets_assoc";

    private final static String FORMAT = "INSERT INTO `test`.`" + ASSOC_TABLE_NAME + "` (`p2000_id`, `tweet_id`, `score`) VALUES ('%1$s', '%2$s', '%3$s');";
    private final static String TWEETS_QUERY =
            "select * " + "from `" + TWEET_TABLE_NAME + "` as t1, `" + TWEET_LABELS_TABLE_NAME + "` as t2 " +
                    "WHERE t1.id = t2.id_tweet";
    private final static String P2000_QUERY =
            "select * " + "from `" + P2000_TABLE_NAME + "` as n, `" + P2000_LABEL_TABLE_NAME + "` as l " +
                    "WHERE l.`notification` = n.`id`" +
                    "ORDER BY  n.`" + P2000.CLUSTER_COLUMN_NAME + "` ASC ";

    private static Assoc[] getAssociations(Cluster[] clusters, TweetCollection tweets) {
        List<Assoc> ret = new ArrayList<>();

        for(Cluster c : clusters) {
            List<Tweet> rel = tweets.getRelevantTweets(c);
            for(Tweet t : rel) {
                double score = 0d;
                for(String s : c.getQuery()) {
                    if(tweets.containsWord(s)) {
                        score += ((double) t.termFrequency(s)) * Math.log(tweets.size() / tweets.getDocumentFrequency(s));
                    }
                }
                ret.add(new Assoc(c.getClusterId(), t.getId(), (float) score));
            }
        }

        return ret.toArray(new Assoc[ret.size()]);
    }

    private static Cluster[] getClusters(P2000[] p) {
        P2000[] p2000s = Arrays.copyOf(p, p.length);

        Comparator<P2000> clusterIdComparator = (o1, o2) -> o1.getCluster() - o2.getCluster();

        Arrays.sort(p2000s, clusterIdComparator);

        List<Cluster> clusters = new ArrayList<>();
        int i;
        for(i = 0; i < p2000s.length; i++) {
            if(p2000s[i].getCluster() == 0) {
                clusters.add(new Cluster(new P2000[]{p2000s[i]}));
            } else {
                break;
            }
        }

        if(i == p2000s.length) {
            return clusters.toArray(new Cluster[clusters.size()]);
        }

        List<P2000> temp = new ArrayList<>();
        int lastCluster = p2000s[i].getCluster();

        for(; i < p2000s.length; i++) {
            if(p2000s[i].getCluster() != lastCluster) {
                clusters.add(new Cluster(temp.toArray(new P2000[temp.size()])));
                temp.clear();
                lastCluster = p2000s[i].getCluster();
            }
            temp.add(p2000s[i]);
        }
        clusters.add(new Cluster(temp.toArray(new P2000[temp.size()])));

        return clusters.toArray(new Cluster[clusters.size()]);
    }

    public static void main(String[] args) throws ParseException {
        if(args.length != 3) {
            System.err.println("Need exactly three arguments");
            System.exit(1);
        }

        String db_host = args[0];
        String user = args[1];
        String pass = args[2];

        try {
            Driver myDriver = new com.mysql.jdbc.Driver();
            DriverManager.registerDriver(myDriver);
        } catch (SQLException e) {
            System.out.println("Error: unable to load driver class!");
            System.exit(2);
        }

        try(Connection conn = DriverManager.getConnection(db_host, user, pass)) {
            Statement s = conn.createStatement();

            ResultSet p2000Rs = s.executeQuery(P2000_QUERY);
            P2000[] p2000s = P2000.getP2000sFromResultSet(p2000Rs);
            p2000Rs.close();
            Cluster[] clusters = getClusters(p2000s);

            ResultSet tweetsRs = s.executeQuery(TWEETS_QUERY);
            TweetCollection tweets = Tweet.getTweetsFromResultSet(tweetsRs);
            tweetsRs.close();

            Assoc[] assocs = getAssociations(clusters, tweets);

            for(Assoc a : assocs) {
                try {
                    s.executeUpdate(String.format(FORMAT, a.getP2000ID(), a.getTweetID(), a.getScore()));
                } catch (SQLException e) {
                    System.err.println("Failed to execute query, because of: ");
                    System.err.println(e.getMessage());
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("Error: could not connect to database!");
            System.exit(3);
        }
    }
}
