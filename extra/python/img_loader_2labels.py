import os
import h5py
import numpy as np
from torch.utils import data
import scipy.misc
import torchvision.transforms as transforms
from PIL import Image

VGG_MEAN = [103.939, 116.779, 123.68]


def normalizeImage(img):
    img = img.astype('float')
    # Do not touch the alpha channel
    for i in range(3):
        minval = img.min()
        maxval = img.max()
        if minval != maxval:
            img -= minval
            img /= (maxval-minval)
    return img*255
data.DataLoader

class img_loader_2labels(data.Dataset):
    def __init__(self, sub_list):
        self.sub_list = sub_list

        osize = [256, 256]

        transform_list = []
        transform_list.append(transforms.Scale(osize, Image.BICUBIC))
        self.transforms_scale = transforms.Compose(transform_list)

        transform_list = []
        transform_list.append(transforms.Scale(osize, Image.NEAREST))
        self.transforms_seg_scale = transforms.Compose(transform_list)

        transform_list = []
        transform_list.append(transforms.ToTensor())
        self.transforms_toTensor = transforms.Compose(transform_list)

        transform_list = []
        transform_list.append(transforms.Normalize((0.5, 0.5, 0.5),
                                            (0.5, 0.5, 0.5)))
        self.transforms_normalize = transforms.Compose(transform_list)

    def __getitem__(self, index):
        # load image
        subinfo = self.sub_list[index]

        sub_name = subinfo[0]
        view_name = subinfo[1]
        img_name = subinfo[2]
        img_dir = subinfo[3]

        img_file = os.path.join(img_dir, img_name)

        A_img = Image.open(img_file).convert('L')

        A_img = self.transforms_scale(A_img)

        A_img = self.transforms_toTensor(A_img)

        data = self.transforms_normalize(A_img)

        return data, sub_name, view_name, img_name


    def __len__(self):
        self.total_count = len(self.sub_list)
        return self.total_count


    def untransform(self, img, lbl):
        img = img.numpy()
        img = img.transpose(1, 2, 0)
        img += np.array(VGG_MEAN)
        img = img.astype(np.uint8)
        img = img[:, :, ::-1]
        lbl = lbl.numpy()
        return img, lbl
