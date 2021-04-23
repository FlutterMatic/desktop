# A simple bash script for appending a path to user environment variable

echo "" >> ~/.bashrc
echo "export PATH=\"\$PATH:$1\"" >> ~/.zshrc