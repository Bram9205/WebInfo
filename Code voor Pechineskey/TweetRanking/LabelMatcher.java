package nl.ramondevaan.tweetranking;

import java.util.ArrayList;
import java.util.List;

public class LabelMatcher {
    private final static List<String> tweetLabels;
    private final static List<String> p2000Labels;
    private final static boolean[][] areRelated;

    static{
        tweetLabels = new ArrayList<>();
        tweetLabels.add("brand");
        tweetLabels.add("brandweer");
        tweetLabels.add("criminaliteit");
        tweetLabels.add("ongeluk");
        tweetLabels.add("politie");
        tweetLabels.add("ambulance");

        p2000Labels = new ArrayList<>();
        p2000Labels.add("ongeval");
        p2000Labels.add("vekeer");
        p2000Labels.add("trein");
        p2000Labels.add("brandweer");
        p2000Labels.add("misdrijf");
        p2000Labels.add("gas");
        p2000Labels.add("dier");
        p2000Labels.add("melding");
        p2000Labels.add("brand");

        areRelated = new boolean[][]{
                {false, false, false, false, false, false, false, false, true},
                {false, false, false, true, false, true, true, true, false},
                {false, false, false, false, true, false, false, false, false},
                {true, true, true, false, false, false, false, false, false},
                {false, true, false, false, true, false, false, false, false},
                {true, false, false, false, false, false, false, false, false}
        };
    }

    public static boolean matches(String tweetLabel, String p2000Label) {
        int tl = tweetLabels.indexOf(tweetLabel);
        int pl = p2000Labels.indexOf(p2000Label);

        return !(tl == -1 || pl == -1) && areRelated[tl][pl];
    }

    public static boolean containsMatch(String tweetLabel, String[] p2000labels) {
        for(String s : p2000labels) {
            if(matches(tweetLabel, s)) {
                return true;
            }
        }

        return false;
    }
}
