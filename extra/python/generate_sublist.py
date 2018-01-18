import os
import numpy as np
#import h5py
import random
import linecache


def mkdir(path):
	if not os.path.exists(path):
		os.makedirs(path)


def dir2list(path,sub_list_file):
    if os.path.exists(sub_list_file):
        fp = open(sub_list_file, 'r')
        sublines = fp.readlines()
        sub_names = []
        for subline in sublines:
            sub_info = subline.replace('\n', '').split(',')
            sub_names.append(sub_info)
        fp.close()
        return sub_names
    else:
        fp = open(sub_list_file, 'w')
        img_root_dir = os.path.join(path,'img')
        subs = os.listdir(img_root_dir)
        subs.sort()
        sub_names = []
        for sub in subs:
            sub_dir = os.path.join(img_root_dir,sub)
            views = os.listdir(sub_dir)
            views.sort()
            for view in views:
                view_dir = os.path.join(sub_dir,view)
                #seg_dir = view_dir.replace('/img/','/seg/')
                slices = os.listdir(view_dir)
                slices.sort()
                for slice in slices:
                    subinfo = (sub,view,slice,view_dir)
                    sub_names.append(subinfo)
                    line = "%s,%s,%s,%s"%(sub,view,slice,view_dir)
                    fp.write(line + "\n")
        fp.close()

