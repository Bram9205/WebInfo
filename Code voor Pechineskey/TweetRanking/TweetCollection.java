package nl.ramondevaan.tweetranking;

import java.util.*;

public class TweetCollection {
    private List<Tweet> tweets;
    private Set<String> wordSet;
    private Map<String, Integer> numDoc;

    public TweetCollection() {
        tweets = new ArrayList<>();
        wordSet = new HashSet<>();
        numDoc = new HashMap<>();
    }

    public boolean add(Tweet tweet) {
        if(tweets.contains(tweet)) {
            return false;
        }

        tweets.add(tweet);
        wordSet.addAll(tweet.getTermFrequencyMap().keySet());

        for(String word : tweet.getTermFrequencyMap().keySet()) {
            numDoc.put(word, numDoc.getOrDefault(word, 0) + 1);
        }

        return true;
    }

    public boolean remove(Tweet tweet) {
        if(!tweets.contains(tweet)) {
            return false;
        }

        Map<String, Integer> wordCount = tweet.getTermFrequencyMap();

        Integer n;

        for(String word : wordCount.keySet()) {
            n = numDoc.get(word) - 1;

            if(n == 0) {
                numDoc.remove(word);
                wordSet.remove(word);
            }else {
                numDoc.put(word, n);
            }
        }

        tweets.remove(tweet);

        return true;
    }

    public void clear() {
        tweets.clear();
        wordSet.clear();
        numDoc.clear();
    }

    public int size() {
        return tweets.size();
    }

    public boolean containsWord(String s) {
        return wordSet.contains(s);
    }

    public int getDocumentFrequency(String s) {
        return numDoc.getOrDefault(s, 0);
    }

    public List<Tweet> getRelevantTweets(Cluster c) {
        if(c.allNone()) {
            return new ArrayList<>();
        }

        List<Tweet> ret = new ArrayList<>();

        for(Tweet t : tweets) {
            NotificationType nt = NotificationType.parseNotificationType(t.getLabel().toLowerCase());

            if(t.getDate() < c.getEarliestTime() || (!c.getNotificationTypes().contains(nt) &&
                    !LabelMatcher.containsMatch(t.getLabel(), c.getLabels()) &&
                    !LabelMatcher.containsMatch(t.getLabel(), c.getSubLabels()))) {
                continue;
            }

            for(P2000 p : c.getNotifications()) {
                boolean cont = false;
                if (p.getTown() != null && !p.getTown().isEmpty() &&
                        (t.getTokenized_text().contains(p.getTown()) || t.getLocation().contains(p.getTown()))) {
                    cont = true;
                }
                if (p.getRegion() != null && !p.getRegion().isEmpty() &&
                        (t.getTokenized_text().contains(p.getRegion()) || t.getLocation().contains(p.getRegion()))) {
                    cont = true;
                }
                if (cont) {
                    ret.add(t);
                    break;
                }
            }
        }

        return ret;
    }
}
