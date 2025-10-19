from curses.ascii import isdigit
import re


def main():
    icons = set()
    pattern = r'IconData\s+(\w+)'
    with open("icons.txt","r") as f:
        lines = f.readlines()
        for line in lines:
            icon = re.findall(pattern,line)
            if icon and not any(c.isdigit() for c in icon[0]):  
                icons.add(icon[0])
    print(icons)
    for icon in icons:
        with open("icons-extracted.txt","a") as f:
            f.write(f"'{icon}' : LucideIcons.{icon},\n")
            
        

if __name__ == "__main__":
    main()