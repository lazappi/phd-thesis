#!/bin/sh

echo "Making PDF..."
make pdf
echo "Making DOCX..."
make docx
echo "Making HTML..."
make html

echo "Proofing HTML..."
htmlproofer ./docs

echo "Done!"
