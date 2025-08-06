# Function to check if a variable is set
check_variable() {
  if [ -z "$1" ]; then
    echo "Error: $2 is not set. Please set the value for $2."
    exit 1
  fi
}