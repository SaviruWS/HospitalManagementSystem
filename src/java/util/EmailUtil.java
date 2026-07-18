package util;

import java.io.InputStream;
import java.util.Properties;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class EmailUtil {

    private static String fromEmail;
    private static String appPassword;

    // Load credentials once, from config.properties on the classpath (WEB-INF/classes).
    // This is more reliable than a raw file path, since it doesn't depend on Tomcat's
    // current working directory.
    static {
        try (InputStream input = EmailUtil.class.getClassLoader().getResourceAsStream("config.properties")) {
            if (input == null) {
                System.out.println("WARNING: config.properties not found on classpath — email sending will fail.");
            } else {
                Properties config = new Properties();
                config.load(input);
                fromEmail = config.getProperty("mail.from");
                appPassword = config.getProperty("mail.password");
                System.out.println("Email config loaded. From: " + fromEmail);
            }
        } catch (Exception e) {
            System.out.println("WARNING: Error loading config.properties — email sending will fail.");
            e.printStackTrace();
        }
    }

    public static void sendEmail(String toEmail, String subject, String body) {

        if (fromEmail == null || appPassword == null) {
            System.out.println("Email not sent — credentials not loaded from config.properties.");
            return;
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, appPassword);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setText(body);

            Transport.send(message);
            System.out.println("Email sent successfully to " + toEmail);

        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
}
