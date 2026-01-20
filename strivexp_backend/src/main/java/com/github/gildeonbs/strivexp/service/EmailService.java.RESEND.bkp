package com.github.gildeonbs.strivexp.service;

import com.resend.Resend;
import com.resend.core.exception.ResendException;
import com.resend.services.emails.model.CreateEmailOptions;
import com.resend.services.emails.model.CreateEmailResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class EmailService {

    private final Resend resend;

    @Value("${app.email.from}")
    private String fromEmail;

    public EmailService(@Value("${resend.api.key}") String apiKey) {
        this.resend = new Resend(apiKey);
    }

    @Async
    public void sendVerificationEmail(String to, String verificationLink) {
        String htmlContent = """
            <html>
            <body>
                <h2>Welcome to StriveXP!</h2>
                <p>Please verify your email address to secure your account and enable future logins.</p>
                <p><a href="%s">Click here to Verify Email</a></p>
                <p>This link expires in 24 hours.</p>
            </body>
            </html>
            """.formatted(verificationLink);

        sendEmail(to, "StriveXP: Verify your email", htmlContent);
    }

    @Async
    public void sendPasswordResetEmail(String to, String resetLink) {
        String htmlContent = """
            <html>
            <body>
                <h2>Password Reset Request</h2>
                <p>We received a request to reset your password for StriveXP.</p>
                <p>Click the link below to set a new password. This link is valid for 15 minutes.</p>
                <a href="%s">Reset Password</a>
                <p>If you did not request this, please ignore this email.</p>
            </body>
            </html>
            """.formatted(resetLink);

        sendEmail(to, "StriveXP: Reset Your Password", htmlContent);
    }

    private void sendEmail(String to, String subject, String htmlContent) {
        try {
            CreateEmailOptions params = CreateEmailOptions.builder()
                    .from(fromEmail)
                    .to(to)
                    .subject(subject)
                    .html(htmlContent)
                    .build();

            CreateEmailResponse data = resend.emails().send(params);
            log.info("Email sent to {} via Resend. ID: {}", to, data.getId());
        } catch (ResendException e) {
            log.error("Failed to send email via Resend to {}", to, e);
        }
    }
}