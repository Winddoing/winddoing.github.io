#!/usr/bin/env python3

# -*- coding: utf-8 -*-
import sys
import glob
import os
from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont

def get_imgs_files(file_dir):
    imgs = []
    for root, dirs, files in os.walk(file_dir):
        for f in files:
            if f.endswith('jpg'):
                imgs.append(os.path.join(root, f))
            if f.endswith('JPG'):
                imgs.append(os.path.join(root, f))
            if f.endswith('jpeg'):
                #imgs.append(os.path.join(root, f))
                print("JPEG:", root + f)
            if f.endswith('png'):
                imgs.append(os.path.join(root, f))
            if f.endswith('PNG'):
                imgs.append(os.path.join(root, f))
    return imgs

def add_watermark_text(img):
    wm_text = "https://winddoing.github.io"

    w = img.size[0]
    h = img.size[1]
    wm_font_sz = max(16, int(w/30))
    wm_text_len = len(wm_text)

    font_type = ImageFont.truetype("/usr/share/fonts/truetype/freefont/FreeMono.ttf", wm_font_sz)
    font_color = (220,220,220)
    draw = ImageDraw.Draw(img)

    #print("wm_font_sz =",wm_font_sz, " wm_text_lent =", wm_text_len)
    #print("w =", w, "h =", h)
    h_step = wm_font_sz * 6
    w_step = wm_text_len * 5
    ww = 0
    for hh in range(1, h):
        if hh % h_step == 0:
            draw.text(xy=(ww, hh), text=wm_text, fill=font_color, font=font_type)
            ww += w_step
            if ww + wm_text_len >= w:
                ww = 0

    if ww == 0:
        draw.text(xy=(w/4, h - wm_font_sz - 1), text=wm_text, fill=font_color, font=font_type)

def retain_file(file):
    retain_f = ["alipay.jpg", "weixin.jpg", "Winddoing.jpg", "apple-touch-icon-next.png", \
            "favicon-16x16-next.png", "favicon-32x32-next.png"]
    for f in retain_f:
        if f in file:
            print("Keep File:", f)
            return 1
    return 0

def watermark(images_dir):
    print("=====>Entry:", images_dir)

    imgs_files = get_imgs_files(images_dir)

    for file in imgs_files:
        if retain_file(file):
            continue

        im = Image.open(file)
        if len(im.getbands()) < 3:
            im = im.convert('RGB')
            print(file)

        add_watermark_text(im)
        print(file)

        im.save(file)


if __name__ == '__main__':
    watermark('public/images/')
    watermark('public/books')
