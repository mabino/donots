# not_mon

Email sending macOS Python script that is triggered on receipt of a notification.  The email includes a screenshot of the desktop.  Useful for Apple Messages notifications that arrive via a secondary (work) iCloud account that isn't directly monitored.

At a minimum, change the `EMAIL_RECIPIENT` to the intended recipient address and the `SENDING_ACCOUNT` to the sender.  The sender is cc'ed.

Run once manually to accept all of the macOS privacy permission prompts.

The simplistic design also has the side benefit of sending an email if there is a mandatory restart or reboot notification.
