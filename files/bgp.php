<?php

// Path to your main XML file
$mainXmlFilePath = '/conf/config.xml';

// Path to the XML file containing the new element
$newElementXmlFilePath = $argv[2];

// Load the main XML file
$mainXml = new DOMDocument;
$mainXml->load($mainXmlFilePath);

// Load the XML file containing the new element
$newElementXml = new DOMDocument;
$newElementXml->load($newElementXmlFilePath);

// Search for the element you want to replace in the main XML (change 'element_to_replace' to the actual element name)
$targetElement = $mainXml->getElementsByTagName($argv[1])->item(0);

// Check if the element is found
if ($targetElement) {
    // Import the new element node into the main document
    $importedNode = $mainXml->importNode($newElementXml->documentElement, true);

    // Find the parent of the target element
    $parent = $targetElement->parentNode;

    // Replace the target element with the imported new element node
    $parent->replaceChild($importedNode, $targetElement);

    // Save the modified main XML back to the file
    $mainXml->save($mainXmlFilePath);

    echo "Element replaced with a new element from another document successfully.";
} else {
    echo "Element not found in the main XML document.";
}
