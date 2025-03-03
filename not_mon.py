def take_notification_screenshot():
    """Takes screenshots of the upper right corner of the screen and emails them together."""
    try:
        if not os.path.exists("notification_screenshots"):
            os.makedirs("notification_screenshots")
            print("Created screenshots directory")

        screen_width, screen_height = get_display_bounds()
        print(f"Detected screen bounds: {screen_width}x{screen_height}")

        x = screen_width - SCREENSHOT_WIDTH + MARGIN_RIGHT
        y = MARGIN_TOP

        print(f"Capturing region: x={x}, y={y}, width={SCREENSHOT_WIDTH}, height={SCREENSHOT_HEIGHT}")

        if INITIAL_DELAY > 0:
            print(f"Waiting initial delay of {INITIAL_DELAY} seconds...")
            time.sleep(INITIAL_DELAY)

        screenshots = []
        for i in range(NUM_SCREENSHOTS):
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"notification_screenshots/notification_{timestamp}_{i+1}.png"

            print(f"Attempting to capture screenshot {i+1}/{NUM_SCREENSHOTS} to: {filename}")

            try:
                # Try to capture the specific region first
                result = subprocess.run([
                    "screencapture",
                    "-R", f"{x},{y},{SCREENSHOT_WIDTH},{SCREENSHOT_HEIGHT}",
                    "-x",
                    filename
                ], capture_output=True, text=True)

                if result.stderr:
                    print(f"screencapture command errors: {result.stderr}")

                # If the capture fails due to no intersection with displays, fall back to full screen
                if result.returncode != 0 or not os.path.exists(filename) or os.path.getsize(filename) == 0:
                    print(f"Error or empty screenshot. Falling back to full screen capture.")
                    filename = f"notification_screenshots/notification_full_{timestamp}_{i+1}.png"
                    result = subprocess.run([
                        "screencapture",
                        "-x",  # Capture the entire screen
                        filename
                    ], capture_output=True, text=True)

                # Check if the screenshot was successfully saved
                if os.path.exists(filename) and os.path.getsize(filename) > 0:
                    print(f"Screenshot saved: {filename}")
                    screenshots.append(filename)
                else:
                    print("Error: Screenshot file was not created or is empty")

                if i < NUM_SCREENSHOTS - 1:
                    time.sleep(SCREENSHOT_DELAY)

            except Exception as e:
                print(f"Error taking screenshot {i+1}: {e}")

        # **Send all screenshots in a single email after capturing completes**
        if screenshots:
            print("Screenshots to attach:", screenshots)
            for path in screenshots:
                if not os.path.exists(path):
                    print(f"Error: Screenshot not found - {path}")
                elif os.path.getsize(path) == 0:
                    print(f"Error: Screenshot is empty - {path}")

            print(f"Attempting to send email with {len(screenshots)} attachments")
            send_email_with_screenshots(screenshots)

        return screenshots

    except Exception as e:
        print(f"Error in take_notification_screenshot: {e}")
        return []
