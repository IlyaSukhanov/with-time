import logging
import time
from collections.abc import Callable
from contextlib import ContextDecorator

logger = logging.getLogger(__name__)


class BasicTimer(ContextDecorator):
    def __init__(self, label: str, timer: Callable[[], float] = time.time):
        self.label = label
        self.timer = timer
        self.start_time = None
        self.end_time = None

    @property
    def elapsed_time(self):
        return self.end_time - self.start_time

    @property
    def message(self):
        # TODO custom message format
        return f"{self.label}: {self.elapsed_time} seconds"

    def emit(self):
        raise NotImplementedError("Emit method is not implemented.")  # pragma: no cover

    def __exit__(self, *_):
        self.end_time = self.timer()
        self.emit()

    def __enter__(self):
        self.start_time = self.timer()
        return self


class LoggingTimer(BasicTimer):
    def emit(self):
        logger.info(self.message)


class PrintingTimer(BasicTimer):
    def emit(self):
        print(self.message)
