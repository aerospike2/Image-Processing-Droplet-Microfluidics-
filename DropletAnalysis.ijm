// -------------------------------------------------------------------------------------------------------------------- //
// ------------------------ ImageJ Macro for generating droplet data using an existing stack -------------------------- //
// -------------------------------------------------------------------------------------------------------------------- //
  
// Abhishek Sharma, BioMIP, Ruhr University, Bochum, Germany
// Last Updated : April, 14th 2014


//id = getId("dropstack");
//name = last_pgmdir;

// Defining threshold limits, for creating a binary image and coordinates for line //
// -----------------------------------------------------------------------  //

dmes_thl = 0
dmes_thh = 25969

dmes_lx1 = 294
dmes_ly1 = 29
dmes_lx2 = 296
dmes_ly2 = 427

// ------------------------------------------------------------------------ //

setBatchMode(true);

//  Enhancing contrast :
run("Enhance Contrast...", "saturated=0.4 normalize update equalize process_all use");

//  Blurring the image (twice) using gaussian blur :
// run("Gaussian Blur...", "sigma=2 stack");
run("Gaussian Blur...", "sigma=2 stack");

// Setting Threshold
setThreshold(dmes_thl, dmes_thh);  // {lower, upper}
run("Convert to Mask", "method=Default background=Light");

// Filling up holes, which remanined during thresholding
//run("Fill Holes", "stack");

// Getting profile along the line saving as data
n = nSlices; // number of slices
h = getHeight();

// Creating line for detection :
makeLine(dmes_lx1,dmes_ly1,dmes_lx2,dmes_ly2);

f = File.open("C:\\Users\\biopro\\Desktop\\tmp.txt");

for(slice=1; slice<=n; slice++){
      showProgress(slice, n);
      setSlice(slice);
      profile = getProfile();
      sliceLabel = toString(slice);
      sliceData = split(getMetadata("Label"), "\n");
      if (sliceData.length>0) {
             line0 = sliceData[0];
             if (lengthOf(sliceLabel) > 0)
                  sliceLabel = sliceLabel+ " ("+ line0 + ")";
      }

//for (i=0; i<profile.length; i++)
//     setResult(sliceLabel,  i,  profile[i]);

droplen = 0;
state = 0;
last = -1;
cnt = 0;
start = -1;
s = "";
p = "";

for (i=0; i<profile.length; i++) {
     if (last == 255 && profile[i] == 0) {
          state = 1;
          droplen = 0;
          cnt++;
          start = i;
      } // 255->0  start drop

      if (last == 0 && profile[i] == 255) {
           state = 2;
           if (cnt > 0 && droplen > 0) {
           // print(sliceLabel," n=", cnt, " l=",droplen);
           s = s + " " + droplen;
           p = p + " " + start;
      }
             } // 0->255 end drop
             if (state == 1) { droplen++; }
             last =  profile[i];
         }

tmp = getMetadata("Label");
len = lengthOf(tmp);
print("Length", len);
if(len > 0)
   time = substring(tmp, len -10, len - 4);
else
   time = 0;
print(sliceLabel, "; ", s, ";      ", p);
// print(f, time + "     " + s + ";      " + p);
//print(f, time + "     " + s + ";      " + p);
s = "";
p = "";

 //------------------------------------------------------------------------------------------------//

gaplen = 0;
state = 0;
last = -1;
cnt = 0;
start = -1;
q = "";
r = "";

for (i=0; i<profile.length; i++) {
      if (last == 0 && profile[i] == 255) {
           state = 1;
           gaplen = 0;
           cnt++;
           start = i;
        } // 0->255  start gap
       if (last == 255 && profile[i] == 0) {
            state = 2;
            if (cnt > 0 && gaplen > 0) {
                  // print(sliceLabel," n=", cnt, " l=",droplen);
                  q = q + " " + gaplen;
                  r = r + " " + start;
              }
        } // 255-> end gap
        if (state == 1) { gaplen++; }
         last =  profile[i];
        }
print(sliceLabel, "; ", q, ";      ", r);
// print(f, sliceLabel + "; " + q + ";      " + r);
print(f,time + "     " + q);
q = "";
r = "";
}

File.close(f);
setBatchMode(false);
//updateResults;

output = exec("python /tmp/Analysis.py");
print(output);

// Change the path accordingly
//saveAs("Results", "/tmp/Results.xls");

# -------------------------------------------------- end - of - file ---------------------------------------------------- #

