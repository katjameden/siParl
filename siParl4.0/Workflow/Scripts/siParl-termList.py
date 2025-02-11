import os
from xml.etree.ElementTree import Element, SubElement, tostring
import xml.etree.ElementTree as ET
import codecs

def create_xml_list_for_subdirectory(folder_path, subdirectory):
    root = Element("documentsList")
    root.tail = '\n'

    subdirectory_path = os.path.join(folder_path, subdirectory)
    if os.path.isdir(subdirectory_path):
        for root_folder, _, files in os.walk(subdirectory_path):
            for filename in files:
                if filename.endswith('.xml'):
                    file_path = os.path.relpath(os.path.join(root_folder, filename), folder_path)
                    ref = SubElement(root, "ref")
                    ref.text = file_path.replace('\\', '/')
                    ref.tail = '\n'

    return tostring(root, encoding='utf-8')

folder_path = 'speech'

subdirectories = ['SSK11', 'SDT2', 'SDT3', 'SDT4', 'SDT5', 'SDT6', 'SDT7', 'SDT8', 'SDZ1', 'SDZ2', 'SDZ3', 'SDZ4', 'SDZ5', 'SDZ6', 'SDZ7', 'SDZ8']


for subdirectory in subdirectories:
    xml_output = create_xml_list_for_subdirectory(folder_path, subdirectory)
    file_name = "speech/%s_list.xml" % subdirectory
    with codecs.open(file_name, 'w', encoding='utf8') as f:
        f.write(xml_output.encode('utf8'))
