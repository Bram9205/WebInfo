package nl.ramondevaan.webinf;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class Main {

    private final static String userAgent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36";
    private final static String format = "INSERT INTO `test`.`alarmcodes` (`id`, `region_id`, `location`, `description`) VALUES ('%1$s', '%2$s', '%3$s', '%4$s');";

    public static void printCommandsSuper(NotificationHandler h, String base_url) throws IOException {
        Document doc = Jsoup.connect(base_url).userAgent(userAgent).get();
        Elements tables = doc.select(".body");
        List<String> urls = new ArrayList<>();
        Elements url_elements = tables.select("a");
        String u;
        for(Element e : url_elements) {
            u = e.attr("abs:href");
            if(!u.isEmpty()) {
                urls.add(u);
            }
        }

        int i = 0;
        for(String s : urls) {
            printCommands(h, s, ++i);
        }
    }

    public static void printCommands(NotificationHandler h, String url, int region) throws IOException {
        Document doc = Jsoup.connect(url).userAgent(userAgent).get();
        Elements rows = doc.select("tr");
        String id, descr, loc;
        boolean first = true;
        for(Element e : rows) {
            if(e.children().size() == 3 && !first) {
                id = e.child(0).text();
                if(!isNumeric(id)) {
                    continue;
                }
                descr = e.child(1).text().replace("'", "\\'");
                loc = e.child(2).text().replace("'", "\\'");

                h.handleNotification(id, region, loc, descr);
            } else {
                first = false;
            }
        }
    }

    private static boolean isNumeric(String str) {
        return str.matches("\\d+");
    }

    public static void main(String[] args) {
        if(args.length != 4) {
            System.err.println("");
        }
		
        String url = args[0];
        String db_host = args[1];
        String user = args[2];
        String pass = args[3];

        try {
            Driver myDriver = new com.mysql.jdbc.Driver();
            DriverManager.registerDriver(myDriver);
        } catch (SQLException e) {
            System.out.println("Error: unable to load driver class!");
            System.exit(1);
        }

        try(Connection conn = DriverManager.getConnection(db_host, user, pass)) {
            Statement s = conn.createStatement();

            printCommandsSuper((id, region, location, description) -> {
                try {
                    s.executeUpdate(String.format(format, id, region + "", location, description));
                } catch (SQLException e) {
                    System.err.println("Failed to execute query, because of: ");
                    System.err.println(e.getMessage());
                }
            }, url);
        } catch (SQLException e) {
            System.err.println("Error: could not connect to database!");
            System.exit(5);
        } catch (IOException e) {
            System.err.println("Error: could not connect to url!");
            System.exit(6);
        }
    }
}
