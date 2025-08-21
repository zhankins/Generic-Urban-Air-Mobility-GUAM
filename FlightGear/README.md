# FlightGear Launcher Script

This folder contains a helper script (`fg-run.sh`) to launch FlightGear with a predefined configuration.  
It is meant to provide a reproducible setup for simulation and networking tests.

## Usage

1. **Download or install FlightGear**  
   If you are using the AppImage, set `FG_APP` in the script to point to your `.AppImage` file.

2. **Set the `fgdata` directory**  
   Edit the placeholder `FG_ROOT` in `fg-run.sh` to match the path to your `fgdata` folder.

3. **Make the script executable**  
   ```bash
   chmod +x fg-run.sh
   ```

4. **Run FlightGear**

   ```bash
   ./fg-run.sh
   ```

## Customization

* Edit the placeholders at the top of `fg-run.sh` (e.g., `FG_AIRPORT`, `FG_RUNWAY`, `FG_ALTITUDE`) to adjust defaults.

## Notes

* The script includes networking and multiplayer configuration for FDM and multiplay ports.
* `--enable-terrasync` is included to automatically fetch scenery.

