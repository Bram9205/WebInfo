package nl.ramondevaan.tweetranking;

public class Assoc {
    private int p2000ID;
    private int tweetID;
    private float score;

    public Assoc(int p2000ID, int tweetID, float score) {
        this.p2000ID = p2000ID;
        this.tweetID = tweetID;
        this.score = score;
    }

    public int getP2000ID() {
        return p2000ID;
    }

    public int getTweetID() {
        return tweetID;
    }

    public float getScore() {
        return score;
    }

    @Override
    public boolean equals(Object other) {
        if (other == null) return false;
        if (other == this) return true;
        if (!(other instanceof Assoc)) return false;
        Assoc otherAssoc = (Assoc) other;
        return otherAssoc.getP2000ID() == this.getP2000ID() && otherAssoc.getTweetID() == this.getTweetID();
    }
}
