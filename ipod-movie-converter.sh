#!/bin/bash

# Default values
BITRATE="1000k"
AUDIO_BITRATE="128k"
FPS="25"
RESOLUTION="320x240"
ASPECT="4:3"
CODEC="mpeg1video"
OUTPUT_DIR="$HOME/Videos/ipod_converted"

# Help function
show_help() {
    echo "iPod Rockbox Video Converter"
    echo "============================="
    echo "Usage: $0 [OPTIONS] <input_file>"
    echo ""
    echo "Options:"
    echo "  -b <bitrate>    Video bitrate (default: 1000k)"
    echo "  -a <bitrate>    Audio bitrate (default: 128k)"
    echo "  -r <fps>        Framerate (default: 25)"
    echo "  -s <WxH>        Resolution (default: 320x240)"
    echo "  -c <codec>      Video codec: mpeg1video or mpeg2video (default: mpeg1video)"
    echo "  -w              Widescreen mode (320x180 with 16:9 aspect)"
    echo "  -o <directory>  Output directory (default: ~/Videos/ipod_converted)"
    echo "  -h              Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 movie.mp4"
    echo "  $0 -b 800k -r 30 -w video.mp4"
    echo "  $0 -o ~/Desktop/converted movie.mp4"
}

# Parse command line arguments
while getopts "b:a:r:s:c:wo:h" opt; do
    case $opt in
        b) BITRATE="$OPTARG" ;;
        a) AUDIO_BITRATE="$OPTARG" ;;
        r) FPS="$OPTARG" ;;
        s) RESOLUTION="$OPTARG" ;;
        c) CODEC="$OPTARG" ;;
        w) 
            RESOLUTION="320x180"
            ASPECT="16:9"
            ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        h)
            show_help
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            show_help
            exit 1
            ;;
    esac
done

# Shift to get the input file
shift $((OPTIND-1))

if [ -z "$1" ]; then
    echo "Error: No input file specified!"
    show_help
    exit 1
fi

INPUT_FILE="$1"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Generate output filename
OUTPUT_FILE="${OUTPUT_DIR}/$(basename "${INPUT_FILE%.*}")_ipod.mpg"

echo "================================="
echo "iPod Rockbox Video Converter"
echo "================================="
echo "Input:      $INPUT_FILE"
echo "Output:     $OUTPUT_FILE"
echo "Output Dir: $OUTPUT_DIR"
echo "Codec:      $CODEC"
echo "Resolution: $RESOLUTION"
echo "Bitrate:    $BITRATE"
echo "Framerate:  $FPS fps"
echo "Aspect:     $ASPECT"
echo "================================="

# Build FFmpeg command
FFMPEG_CMD="ffmpeg -i \"$INPUT_FILE\" \
  -c:v $CODEC \
  -b:v $BITRATE \
  -r $FPS \
  -s $RESOLUTION \
  -aspect $ASPECT \
  -c:a mp2 \
  -b:a $AUDIO_BITRATE \
  -f mpeg \
  \"$OUTPUT_FILE\""

echo "Converting..."

# Execute command
eval "$FFMPEG_CMD"

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Conversion successful!"
    echo "  Output: $OUTPUT_FILE"
    echo "  Size: $(du -h "$OUTPUT_FILE" | cut -f1)"
    
    # Show video info
    echo ""
    echo "Video information:"
    ffmpeg -i "$OUTPUT_FILE" 2>&1 | grep -E "(Duration|Stream|bitrate|fps)"
else
    echo ""
    echo "✗ Conversion failed!"
    exit 1
fi
