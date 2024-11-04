# 📽️ MediaBrowser

### MediaBrowser is a data type impartial browser which renders and caches all\* the types media.

<img width="1624" alt="MediaBrowser Architecture" src="https://github.com/user-attachments/assets/1e628a48-6c4d-4972-a6fc-9b319266c3e1">


Media Browser currently supports 5 types of Media rendering

* Image via UIImage
* Image via URL
* Video
* Documents (PDF, docs etc)
* WebViews


## Mechanism

The ideal process of Media Browser happens the following way:

<img width="1624" alt="Basic Mechanism" src="https://github.com/user-attachments/assets/1d5ea0ca-b1b8-42a2-9c22-6c60e9edfdc2">

## 📒 How to Use?

When we need to render any form of media we primarily have three data formats

* URL
* Data
* UIImage

Since Media Browser only understands `MediaBrowsable` type data, we need to convert the raw data to required type

To perform this operation there are extensions written:

![MediaBrowser Converter](https://github.com/user-attachments/assets/31da3ddc-f960-40e6-84b2-05eaf1ec90cc)


Once you have converted raw data to MediaBrowsable type, then use the render() method of media browser to render media.


 ![MediaBrowser Presentation](https://github.com/user-attachments/assets/5137beac-4564-46c0-96ad-4d2c300cfafb)


Now while initialising MediaBrowser, you need to specify a storage policy to media browser. Available storage policies are:



1. **InMemory**

InMemory storage policy stores/caches the rendered media in Browser class. Thus the data will get disposed when Media Browser session is ended.

Such kind of policy is used when temporary browsing is required. Here data is captured till the browser session.



2. **UsingNSCache**

UsingNSCache storage policy caches the rendered media for entire app life cycle. Thus the data will get disposed when the app is killed.

Such kind of policy is used when there is frequent demand of media browsing required.



3. **DiskStorage**

DiskStorage storage policy caches the rendered media until disk gets out of space or the disk is not cleared. Thus the data will not get disposed even when the app is killed.

Such kind of policy is best used when there are constant images to be rendered repetitively.


> By Default **InMemory** is set as storage policy

## 🚀 Utility Methods

1. **Placeholder** 

You can set custom placeholder image for browser

![MediaBrowser Image](https://github.com/user-attachments/assets/8cf60543-ccc9-4c5e-85b3-dbc98ba63bf0)

