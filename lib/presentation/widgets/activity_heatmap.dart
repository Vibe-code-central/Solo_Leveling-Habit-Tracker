import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ActivityHeatmap extends StatelessWidget {
  final Map<DateTime, int> activityData;
  final int daysToShow;

  const ActivityHeatmap({
    super.key,
    required this.activityData,
    this.daysToShow = 91, // ~3 months (13 weeks)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.systemNavy,
        border: Border.all(color: AppTheme.primaryPurple),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_on, color: AppTheme.primaryPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                'HUNTER ACTIVITY LOG',
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryPurple,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Heatmap Grid
          _buildGrid(context),

          const SizedBox(height: 12),

          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final now = DateTime.now();
    // Normalize to midnight
    final today = DateTime(now.year, now.month, now.day);

    // Calculate start date (Sunday of the week X days ago?)
    // This simple grid will just show X days ending today, organized by week columns.
    // 7 rows (Sun-Sat or Mon-Sun).

    // Rows = 7. Columns = ceil(daysToShow / 7).

    final int columns = (daysToShow / 7).ceil();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true, // Scroll to end (today)
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(columns, (colIndex) {
          // Column 0 is the oldest week? Or newest?
          // Let's make Column 0 the OLDEST (left) and last Column the NEWEST (right).

          // Start date of the whole grid:
          // We want the last column to end on Today (or simply show the last 13 weeks).
          // Let's anchor "End" to today.

          // The last column index is (columns-1).
          // date = today - (columns - 1 - colIndex) * 7 - row?
          // This is getting complex math.

          // Simpler: Just generate a flat list of days and wrap in Wrap? No, we want grid alignment.
          // Standard Heatmap:
          // Columns represent Weeks.
          // Rows represent Days (Mon, Tue...).

          return Container(
            margin: const EdgeInsets.only(right: 4),
            child: Column(
              children: List.generate(7, (rowIndex) {
                // Determine exact date for this cell
                // We want the grid to end at 'Today'.
                // So the bottom-right cell (or close to it) is Today.

                // Let's calculate backwards from Today.
                // Today is at: col = last, row = today.weekday.

                // Let's calculate the date of the cell
                // date = startOfGrid + (col * 7) + row

                // How to find startOfGrid?
                // It should be roughly today - daysToShow.
                // Adjusted to start on a Sunday?

                final startOfWeek =
                    today.subtract(Duration(days: today.weekday % 7)); // Sunday
                // If today is Tuesday, weekday=2. subtract 2 days = Sunday.

                // We want 'columns' weeks.
                // Start date of the grid = startOfWeek - (columns - 1) weeks.
                final gridStartDate =
                    startOfWeek.subtract(Duration(days: (columns - 1) * 7));

                final cellDate = gridStartDate
                    .add(Duration(days: (colIndex * 7) + rowIndex));

                // If cellDate > today, don't render or render empty?
                if (cellDate.isAfter(today)) {
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(bottom: 4),
                  );
                }

                final count = activityData[cellDate] ?? 0;

                return _buildCell(count, cellDate);
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCell(int count, DateTime date) {
    Color color;
    if (count == 0) {
      color = AppTheme.darkBg.withOpacity(0.5); // Empty
    } else if (count <= 2) {
      color = AppTheme.primaryPurple.withOpacity(0.4);
    } else if (count <= 4) {
      color = AppTheme.primaryPurple;
    } else if (count <= 6) {
      color = AppTheme.electricBlue;
    } else {
      color = AppTheme.systemCyan;
    }

    return Tooltip(
      message: '${_formatDate(date)}: $count quests',
      child: Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
          border: count > 0 ? null : Border.all(color: Colors.white10),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Less',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        const SizedBox(width: 4),
        _buildLegendBox(AppTheme.darkBg.withOpacity(0.5)),
        const SizedBox(width: 2),
        _buildLegendBox(AppTheme.primaryPurple.withOpacity(0.4)),
        const SizedBox(width: 2),
        _buildLegendBox(AppTheme.primaryPurple),
        const SizedBox(width: 2),
        _buildLegendBox(AppTheme.electricBlue),
        const SizedBox(width: 2),
        _buildLegendBox(AppTheme.systemCyan),
        const SizedBox(width: 4),
        Text('More',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
      ],
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}";
  }
}
