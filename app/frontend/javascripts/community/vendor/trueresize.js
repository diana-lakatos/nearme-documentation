/*!
 * (v) True resize helper (v20150214)
 * Helper for resize event in mobile devices to tell if window width has changed
 */
(function(){window.trueResize=function(){var w=window,d=document,e=d.documentElement,g=d.getElementsByTagName('body')[0],x=w.innerWidth||e.clientWidth||g.clientWidth,y=w.innerHeight||e.clientHeight||g.clientHeight,p=window.previousWidth||0;if(p==x){return false;}else{window.previousWidth=x;return true;}};})();
