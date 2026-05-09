import io
import tempfile
import unittest
from pathlib import Path

from scripts.summarize_depth import summarize_depth_file, summarize_depth_stream
from scripts.summarize_duplicate_fragments import (
    summarize_duplicate_sam,
    write_duplicate_reports,
)


class SummarizeDepthTests(unittest.TestCase):
    def test_summarizes_depth_thresholds(self):
        with tempfile.TemporaryDirectory() as tmp:
            depth_path = Path(tmp) / "depth.tsv"
            depth_path.write_text(
                "chr1\t10\t0\n"
                "chr1\t11\t49\n"
                "chr1\t12\t50\n"
                "chr1\t13\t100\n",
                encoding="utf-8",
            )

            summary = summarize_depth_file(depth_path, thresholds=[1, 50, 100])

        self.assertEqual(summary["bases"], 4)
        self.assertEqual(summary["mean_depth"], 49.75)
        self.assertEqual(summary["median_depth"], 49.5)
        self.assertEqual(summary["pct_ge_1x"], 75.0)
        self.assertEqual(summary["pct_ge_50x"], 50.0)
        self.assertEqual(summary["pct_ge_100x"], 25.0)

    def test_summarizes_streamed_depth(self):
        depth_stream = io.StringIO(
            "chr1\t10\t10\n"
            "chr1\t11\t20\n"
            "chr1\t12\t30\n"
        )

        summary = summarize_depth_stream(depth_stream, thresholds=[20])

        self.assertEqual(summary["bases"], 3)
        self.assertEqual(summary["mean_depth"], 20.0)
        self.assertEqual(summary["median_depth"], 20.0)
        self.assertEqual(summary["pct_ge_20x"], 66.6667)

    def test_duplicate_fragment_summary_detects_concentration(self):
        sam = io.StringIO(
            "readA\t1089\tchr1\t100\t60\t150M\t=\t250\t300\t*\t*\n"
            "readB\t1089\tchr1\t100\t60\t150M\t=\t250\t300\t*\t*\n"
            "readC\t1089\tchr1\t500\t60\t150M\t=\t650\t300\t*\t*\n"
        )

        summary = summarize_duplicate_sam(sam)

        self.assertEqual(summary["duplicate_read1_records"], 3)
        self.assertEqual(summary["duplicate_fragment_keys"], 2)
        self.assertEqual(summary["top_fragment_duplicate_read1_count"], 2)
        self.assertAlmostEqual(summary["top10_fragment_fraction"], 100.0)

    def test_duplicate_fragment_reports_include_top_fragments_and_histogram(self):
        sam = io.StringIO(
            "readA\t1089\tchr1\t100\t60\t150M\t=\t250\t300\t*\t*\n"
            "readB\t1089\tchr1\t100\t60\t150M\t=\t250\t300\t*\t*\n"
            "readC\t1089\tchr1\t500\t60\t150M\t=\t650\t300\t*\t*\n"
        )

        report = summarize_duplicate_sam(sam)

        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            write_duplicate_reports(
                report,
                summary_path=tmp_path / "summary.tsv",
                top_path=tmp_path / "top.tsv",
                histogram_path=tmp_path / "histogram.tsv",
            )

            top_lines = (tmp_path / "top.tsv").read_text(encoding="utf-8").splitlines()
            histogram_lines = (tmp_path / "histogram.tsv").read_text(encoding="utf-8").splitlines()

        self.assertEqual(top_lines[0], "rank\tchrom\tleft_pos\ttemplate_length\torientation\tduplicate_read1_count")
        self.assertEqual(top_lines[1], "1\tchr1\t100\t300\t0\t2")
        self.assertIn("2\t1\t2", histogram_lines)
        self.assertIn("1\t1\t1", histogram_lines)


if __name__ == "__main__":
    unittest.main()
