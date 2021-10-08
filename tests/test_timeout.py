import contextlib
import io
import time
from unittest import TestCase

from with_time import LoggingTimer, PrintingTimer


class TestLoggingTimer(TestCase):
    def test_log_context_manager(self):
        with self.assertLogs(level="INFO") as log:
            with LoggingTimer("sleep"):
                time.sleep(0.1)
            self.assertEqual(len(log.records), 1)
            self.assertIn("sleep", log.output[0])

    def test_log_decorator(self):
        @LoggingTimer("hello")
        def foo():
            time.sleep(0.1)

        with self.assertLogs(level="INFO") as log:
            foo()
            self.assertEqual(len(log.records), 1)
            self.assertIn("hello", log.output[0])

    def test_log_context_manager_process_time(self):
        with self.assertLogs(level="INFO") as log:
            with LoggingTimer("sleep", timer=time.process_time) as timer:
                time.sleep(0.1)
            self.assertEqual(len(log.records), 1)
            self.assertIn("sleep", log.output[0])
            assert timer.elapsed_time < 0.01


class TestPrintingTimer(TestCase):
    def test_log_context_manager(self):
        stdout = io.StringIO()
        with contextlib.redirect_stdout(stdout):
            with PrintingTimer("sleep"):
                time.sleep(0.1)
        assert "sleep" in stdout.getvalue()
