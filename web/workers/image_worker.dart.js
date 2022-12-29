(function dartProgram(){function copyProperties(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
b[q]=a[q]}}function mixinPropertiesHard(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
if(!b.hasOwnProperty(q))b[q]=a[q]}}function mixinPropertiesEasy(a,b){Object.assign(b,a)}var z=function(){var s=function(){}
s.prototype={p:{}}
var r=new s()
if(!(r.__proto__&&r.__proto__.p===s.prototype.p))return false
try{if(typeof navigator!="undefined"&&typeof navigator.userAgent=="string"&&navigator.userAgent.indexOf("Chrome/")>=0)return true
if(typeof version=="function"&&version.length==0){var q=version()
if(/^\d+\.\d+\.\d+\.\d+$/.test(q))return true}}catch(p){}return false}()
function inherit(a,b){a.prototype.constructor=a
a.prototype["$i"+a.name]=a
if(b!=null){if(z){a.prototype.__proto__=b.prototype
return}var s=Object.create(b.prototype)
copyProperties(a.prototype,s)
a.prototype=s}}function inheritMany(a,b){for(var s=0;s<b.length;s++)inherit(b[s],a)}function mixinEasy(a,b){mixinPropertiesEasy(b.prototype,a.prototype)
a.prototype.constructor=a}function mixinHard(a,b){mixinPropertiesHard(b.prototype,a.prototype)
a.prototype.constructor=a}function lazyOld(a,b,c,d){var s=a
a[b]=s
a[c]=function(){a[c]=function(){A.ql(b)}
var r
var q=d
try{if(a[b]===s){r=a[b]=q
r=a[b]=d()}else r=a[b]}finally{if(r===q)a[b]=null
a[c]=function(){return this[b]}}return r}}function lazy(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s)a[b]=d()
a[c]=function(){return this[b]}
return a[b]}}function lazyFinal(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){var r=d()
if(a[b]!==s)A.mz(b)
a[b]=r}var q=a[b]
a[c]=function(){return q}
return q}}function makeConstList(a){a.immutable$list=Array
a.fixed$length=Array
return a}function convertToFastObject(a){function t(){}t.prototype=a
new t()
return a}function convertAllToFastObject(a){for(var s=0;s<a.length;++s)convertToFastObject(a[s])}var y=0
function instanceTearOffGetter(a,b){var s=null
return a?function(c){if(s===null)s=A.kx(b)
return new s(c,this)}:function(){if(s===null)s=A.kx(b)
return new s(this,null)}}function staticTearOffGetter(a){var s=null
return function(){if(s===null)s=A.kx(a).prototype
return s}}var x=0
function tearOffParameters(a,b,c,d,e,f,g,h,i,j){if(typeof h=="number")h+=x
return{co:a,iS:b,iI:c,rC:d,dV:e,cs:f,fs:g,fT:h,aI:i||0,nDA:j}}function installStaticTearOff(a,b,c,d,e,f,g,h){var s=tearOffParameters(a,true,false,c,d,e,f,g,h,false)
var r=staticTearOffGetter(s)
a[b]=r}function installInstanceTearOff(a,b,c,d,e,f,g,h,i,j){c=!!c
var s=tearOffParameters(a,false,c,d,e,f,g,h,i,!!j)
var r=instanceTearOffGetter(c,s)
a[b]=r}function setOrUpdateInterceptorsByTag(a){var s=v.interceptorsByTag
if(!s){v.interceptorsByTag=a
return}copyProperties(a,s)}function setOrUpdateLeafTags(a){var s=v.leafTags
if(!s){v.leafTags=a
return}copyProperties(a,s)}function updateTypes(a){var s=v.types
var r=s.length
s.push.apply(s,a)
return r}function updateHolder(a,b){copyProperties(b,a)
return a}var hunkHelpers=function(){var s=function(a,b,c,d,e){return function(f,g,h,i){return installInstanceTearOff(f,g,a,b,c,d,[h],i,e,false)}},r=function(a,b,c,d){return function(e,f,g,h){return installStaticTearOff(e,f,a,b,c,[g],h,d)}}
return{inherit:inherit,inheritMany:inheritMany,mixin:mixinEasy,mixinHard:mixinHard,installStaticTearOff:installStaticTearOff,installInstanceTearOff:installInstanceTearOff,_instance_0u:s(0,0,null,["$0"],0),_instance_1u:s(0,1,null,["$1"],0),_instance_2u:s(0,2,null,["$2"],0),_instance_0i:s(1,0,null,["$0"],0),_instance_1i:s(1,1,null,["$1"],0),_instance_2i:s(1,2,null,["$2"],0),_static_0:r(0,null,["$0"],0),_static_1:r(1,null,["$1"],0),_static_2:r(2,null,["$2"],0),makeConstList:makeConstList,lazy:lazy,lazyFinal:lazyFinal,lazyOld:lazyOld,updateHolder:updateHolder,convertToFastObject:convertToFastObject,updateTypes:updateTypes,setOrUpdateInterceptorsByTag:setOrUpdateInterceptorsByTag,setOrUpdateLeafTags:setOrUpdateLeafTags}}()
function initializeDeferredHunk(a){x=v.types.length
a(hunkHelpers,v,w,$)}var A={jZ:function jZ(){},
nG(a){return new A.bD("Field '"+a+"' has been assigned during initialization.")},
hx(a){return new A.bD("Field '"+a+"' has not been initialized.")},
cl(a,b,c){return a},
kd(a,b,c,d){A.eX(b,"start")
if(c!=null){A.eX(c,"end")
if(b>c)A.F(A.Q(b,0,c,"start",null))}return new A.d7(a,b,c,d.l("d7<0>"))},
k3(a,b,c,d){if(t.gt.b(a))return new A.by(a,b,c.l("@<0>").G(d).l("by<1,2>"))
return new A.aR(a,b,c.l("@<0>").G(d).l("aR<1,2>"))},
bC(){return new A.ca("No element")},
l6(){return new A.ca("Too few elements")},
bD:function bD(a){this.a=a},
a8:function a8(a){this.a=a},
jL:function jL(){},
r:function r(){},
X:function X(){},
d7:function d7(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.$ti=d},
bF:function bF(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
aR:function aR(a,b,c){this.a=a
this.b=b
this.$ti=c},
by:function by(a,b,c){this.a=a
this.b=b
this.$ti=c},
cU:function cU(a,b,c){var _=this
_.a=null
_.b=a
_.c=b
_.$ti=c},
aS:function aS(a,b,c){this.a=a
this.b=b
this.$ti=c},
W:function W(a,b,c){this.a=a
this.b=b
this.$ti=c},
dk:function dk(a,b,c){this.a=a
this.b=b
this.$ti=c},
cx:function cx(a,b,c){this.a=a
this.b=b
this.$ti=c},
cy:function cy(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
bz:function bz(a){this.$ti=a},
cu:function cu(a){this.$ti=a},
a2:function a2(){},
bk:function bk(){},
cc:function cc(){},
nt(a){if(typeof a=="number")return B.c.gaf(a)
if(t.ha.b(a))return A.d_(a)
return A.mu(a)},
nu(a){return new A.h5(a)},
mA(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
qc(a,b){var s
if(b!=null){s=b.x
if(s!=null)return s}return t.dX.b(a)},
v(a){var s
if(typeof a=="string")return a
if(typeof a=="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
s=J.bR(a)
return s},
d_(a){var s,r=$.lm
if(r==null)r=$.lm=Symbol("identityHashCode")
s=a[r]
if(s==null){s=Math.random()*0x3fffffff|0
a[r]=s}return s},
hP(a){return A.nP(a)},
nP(a){var s,r,q,p
if(a instanceof A.t)return A.al(A.S(a),null)
s=J.cn(a)
if(s===B.b0||s===B.b5||t.cx.b(a)){r=B.a1(a)
if(r!=="Object"&&r!=="")return r
q=a.constructor
if(typeof q=="function"){p=q.name
if(typeof p=="string"&&p!=="Object"&&p!=="")return p}}return A.al(A.S(a),null)},
ll(a){var s,r,q,p,o=a.length
if(o<=500)return String.fromCharCode.apply(null,a)
for(s="",r=0;r<o;r=q){q=r+500
p=q<o?q:o
s+=String.fromCharCode.apply(null,a.slice(r,p))}return s},
nQ(a){var s,r,q,p=A.b([],t.t)
for(s=a.length,r=0;r<a.length;a.length===s||(0,A.b3)(a),++r){q=a[r]
if(!A.jr(q))throw A.d(A.br(q))
if(q<=65535)B.b.A(p,q)
else if(q<=1114111){B.b.A(p,55296+(B.a.i(q-65536,10)&1023))
B.b.A(p,56320+(q&1023))}else throw A.d(A.br(q))}return A.ll(p)},
lt(a){var s,r,q
for(s=a.length,r=0;r<s;++r){q=a[r]
if(!A.jr(q))throw A.d(A.br(q))
if(q<0)throw A.d(A.br(q))
if(q>65535)return A.nQ(a)}return A.ll(a)},
nR(a,b,c){var s,r,q,p
if(c<=500&&b===0&&c===a.length)return String.fromCharCode.apply(null,a)
for(s=b,r="";s<c;s=q){q=s+500
p=q<c?q:c
r+=String.fromCharCode.apply(null,a.subarray(s,p))}return r},
B(a){var s
if(a<=65535)return String.fromCharCode(a)
if(a<=1114111){s=a-65536
return String.fromCharCode((B.a.i(s,10)|55296)>>>0,s&1023|56320)}throw A.d(A.Q(a,0,1114111,null,null))},
ak(a){if(a.date===void 0)a.date=new Date(a.a)
return a.date},
eO(a){return a.b?A.ak(a).getUTCFullYear()+0:A.ak(a).getFullYear()+0},
lr(a){return a.b?A.ak(a).getUTCMonth()+1:A.ak(a).getMonth()+1},
ln(a){return a.b?A.ak(a).getUTCDate()+0:A.ak(a).getDate()+0},
lo(a){return a.b?A.ak(a).getUTCHours()+0:A.ak(a).getHours()+0},
lq(a){return a.b?A.ak(a).getUTCMinutes()+0:A.ak(a).getMinutes()+0},
ls(a){return a.b?A.ak(a).getUTCSeconds()+0:A.ak(a).getSeconds()+0},
lp(a){return a.b?A.ak(a).getUTCMilliseconds()+0:A.ak(a).getMilliseconds()+0},
D(a){throw A.d(A.br(a))},
a(a,b){if(a==null)J.b5(a)
throw A.d(A.cm(a,b))},
cm(a,b){var s,r="index",q=null
if(!A.jr(b))return new A.aF(!0,b,r,q)
s=A.o(J.b5(a))
if(b<0||b>=s)return A.hn(b,a,r,q,s)
return new A.d3(q,q,!0,b,r,"Value not in range")},
pZ(a,b,c){if(a<0||a>c)return A.Q(a,0,c,"start",null)
if(b!=null)if(b<a||b>c)return A.Q(b,a,c,"end",null)
return new A.aF(!0,b,"end",null)},
br(a){return new A.aF(!0,a,null,null)},
d(a){var s,r
if(a==null)a=new A.eJ()
s=new Error()
s.dartException=a
r=A.qm
if("defineProperty" in Object){Object.defineProperty(s,"message",{get:r})
s.name=""}else s.toString=r
return s},
qm(){return J.bR(this.dartException)},
F(a){throw A.d(a)},
b3(a){throw A.d(A.ba(a))},
aU(a){var s,r,q,p,o,n
a=A.qj(a.replace(String({}),"$receiver$"))
s=a.match(/\\\$[a-zA-Z]+\\\$/g)
if(s==null)s=A.b([],t.s)
r=s.indexOf("\\$arguments\\$")
q=s.indexOf("\\$argumentsExpr\\$")
p=s.indexOf("\\$expr\\$")
o=s.indexOf("\\$method\\$")
n=s.indexOf("\\$receiver\\$")
return new A.i6(a.replace(new RegExp("\\\\\\$arguments\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$argumentsExpr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$expr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$method\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$receiver\\\\\\$","g"),"((?:x|[^x])*)"),r,q,p,o,n)},
i7(a){return function($expr$){var $argumentsExpr$="$arguments$"
try{$expr$.$method$($argumentsExpr$)}catch(s){return s.message}}(a)},
lH(a){return function($expr$){try{$expr$.$method$}catch(s){return s.message}}(a)},
k_(a,b){var s=b==null,r=s?null:b.method
return new A.ew(a,r,s?null:b.receiver)},
a0(a){var s
if(a==null)return new A.hH(a)
if(a instanceof A.cw){s=a.a
return A.bs(a,s==null?t.K.a(s):s)}if(typeof a!=="object")return a
if("dartException" in a)return A.bs(a,a.dartException)
return A.pO(a)},
bs(a,b){if(t.Q.b(b))if(b.$thrownJsError==null)b.$thrownJsError=a
return b},
pO(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=null
if(!("message" in a))return a
s=a.message
if("number" in a&&typeof a.number=="number"){r=a.number
q=r&65535
if((B.a.i(r,16)&8191)===10)switch(q){case 438:return A.bs(a,A.k_(A.v(s)+" (Error "+q+")",e))
case 445:case 5007:p=A.v(s)
return A.bs(a,new A.cY(p+" (Error "+q+")",e))}}if(a instanceof TypeError){o=$.mE()
n=$.mF()
m=$.mG()
l=$.mH()
k=$.mK()
j=$.mL()
i=$.mJ()
$.mI()
h=$.mN()
g=$.mM()
f=o.aD(s)
if(f!=null)return A.bs(a,A.k_(A.a_(s),f))
else{f=n.aD(s)
if(f!=null){f.method="call"
return A.bs(a,A.k_(A.a_(s),f))}else{f=m.aD(s)
if(f==null){f=l.aD(s)
if(f==null){f=k.aD(s)
if(f==null){f=j.aD(s)
if(f==null){f=i.aD(s)
if(f==null){f=l.aD(s)
if(f==null){f=h.aD(s)
if(f==null){f=g.aD(s)
p=f!=null}else p=!0}else p=!0}else p=!0}else p=!0}else p=!0}else p=!0}else p=!0
if(p){A.a_(s)
return A.bs(a,new A.cY(s,f==null?e:f.method))}}}return A.bs(a,new A.f9(typeof s=="string"?s:""))}if(a instanceof RangeError){if(typeof s=="string"&&s.indexOf("call stack")!==-1)return new A.d6()
s=function(b){try{return String(b)}catch(d){}return null}(a)
return A.bs(a,new A.aF(!1,e,e,typeof s=="string"?s.replace(/^RangeError:\s*/,""):s))}if(typeof InternalError=="function"&&a instanceof InternalError)if(typeof s=="string"&&s==="too much recursion")return new A.d6()
return a},
an(a){var s
if(a instanceof A.cw)return a.b
if(a==null)return new A.dA(a)
s=a.$cachedTrace
if(s!=null)return s
return a.$cachedTrace=new A.dA(a)},
mu(a){if(a==null||typeof a!="object")return J.dQ(a)
else return A.d_(a)},
mq(a,b){var s,r,q,p=a.length
for(s=0;s<p;s=q){r=s+1
q=r+1
b.h(0,a[s],a[r])}return b},
qb(a,b,c,d,e,f){t.Y.a(a)
switch(A.o(b)){case 0:return a.$0()
case 1:return a.$1(c)
case 2:return a.$2(c,d)
case 3:return a.$3(c,d,e)
case 4:return a.$4(c,d,e,f)}throw A.d(A.kX("Unsupported number of arguments for wrapped closure"))},
bQ(a,b){var s
if(a==null)return null
s=a.$identity
if(!!s)return s
s=function(c,d,e){return function(f,g,h,i){return e(c,d,f,g,h,i)}}(a,b,A.qb)
a.$identity=s
return s},
ne(a2){var s,r,q,p,o,n,m,l,k,j,i=a2.co,h=a2.iS,g=a2.iI,f=a2.nDA,e=a2.aI,d=a2.fs,c=a2.cs,b=d[0],a=c[0],a0=i[b],a1=a2.fT
a1.toString
s=h?Object.create(new A.eZ().constructor.prototype):Object.create(new A.bU(null,null).constructor.prototype)
s.$initialize=s.constructor
if(h)r=function static_tear_off(){this.$initialize()}
else r=function tear_off(a3,a4){this.$initialize(a3,a4)}
s.constructor=r
r.prototype=s
s.$_name=b
s.$_target=a0
q=!h
if(q)p=A.kT(b,a0,g,f)
else{s.$static_name=b
p=a0}s.$S=A.na(a1,h,g)
s[a]=p
for(o=p,n=1;n<d.length;++n){m=d[n]
if(typeof m=="string"){l=i[m]
k=m
m=l}else k=""
j=c[n]
if(j!=null){if(q)m=A.kT(k,m,g,f)
s[j]=m}if(n===e)o=m}s.$C=o
s.$R=a2.rC
s.$D=a2.dV
return r},
na(a,b,c){if(typeof a=="number")return a
if(typeof a=="string"){if(b)throw A.d("Cannot compute signature for static tearoff.")
return function(d,e){return function(){return e(this,d)}}(a,A.n6)}throw A.d("Error in functionType of tearoff")},
nb(a,b,c,d){var s=A.kS
switch(b?-1:a){case 0:return function(e,f){return function(){return f(this)[e]()}}(c,s)
case 1:return function(e,f){return function(g){return f(this)[e](g)}}(c,s)
case 2:return function(e,f){return function(g,h){return f(this)[e](g,h)}}(c,s)
case 3:return function(e,f){return function(g,h,i){return f(this)[e](g,h,i)}}(c,s)
case 4:return function(e,f){return function(g,h,i,j){return f(this)[e](g,h,i,j)}}(c,s)
case 5:return function(e,f){return function(g,h,i,j,k){return f(this)[e](g,h,i,j,k)}}(c,s)
default:return function(e,f){return function(){return e.apply(f(this),arguments)}}(d,s)}},
kT(a,b,c,d){var s,r
if(c)return A.nd(a,b,d)
s=b.length
r=A.nb(s,d,a,b)
return r},
nc(a,b,c,d){var s=A.kS,r=A.n7
switch(b?-1:a){case 0:throw A.d(new A.eY("Intercepted function with no arguments."))
case 1:return function(e,f,g){return function(){return f(this)[e](g(this))}}(c,r,s)
case 2:return function(e,f,g){return function(h){return f(this)[e](g(this),h)}}(c,r,s)
case 3:return function(e,f,g){return function(h,i){return f(this)[e](g(this),h,i)}}(c,r,s)
case 4:return function(e,f,g){return function(h,i,j){return f(this)[e](g(this),h,i,j)}}(c,r,s)
case 5:return function(e,f,g){return function(h,i,j,k){return f(this)[e](g(this),h,i,j,k)}}(c,r,s)
case 6:return function(e,f,g){return function(h,i,j,k,l){return f(this)[e](g(this),h,i,j,k,l)}}(c,r,s)
default:return function(e,f,g){return function(){var q=[g(this)]
Array.prototype.push.apply(q,arguments)
return e.apply(f(this),q)}}(d,r,s)}},
nd(a,b,c){var s,r
if($.kQ==null)$.kQ=A.kP("interceptor")
if($.kR==null)$.kR=A.kP("receiver")
s=b.length
r=A.nc(s,c,a,b)
return r},
kx(a){return A.ne(a)},
n6(a,b){return A.jk(v.typeUniverse,A.S(a.a),b)},
kS(a){return a.a},
n7(a){return a.b},
kP(a){var s,r,q,p=new A.bU("receiver","interceptor"),o=J.l9(Object.getOwnPropertyNames(p),t.X)
for(s=o.length,r=0;r<s;++r){q=o[r]
if(p[q]===a)return q}throw A.d(A.bu("Field name "+a+" not found.",null))},
b0(a){if(a==null)A.pQ("boolean expression must not be null")
return a},
pQ(a){throw A.d(new A.fi(a))},
ql(a){throw A.d(new A.dZ(a))},
q3(a){return v.getIsolateTag(a)},
cQ(a,b,c){var s=new A.bE(a,b,c.l("bE<0>"))
s.c=a.e
return s},
rW(a,b,c){Object.defineProperty(a,b,{value:c,enumerable:false,writable:true,configurable:true})},
qe(a){var s,r,q,p,o,n=A.a_($.ms.$1(a)),m=$.jA[n]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.jI[n]
if(s!=null)return s
r=v.interceptorsByTag[n]
if(r==null){q=A.kr($.mj.$2(a,n))
if(q!=null){m=$.jA[q]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.jI[q]
if(s!=null)return s
r=v.interceptorsByTag[q]
n=q}}if(r==null)return null
s=r.prototype
p=n[0]
if(p==="!"){m=A.jK(s)
$.jA[n]=m
Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}if(p==="~"){$.jI[n]=s
return s}if(p==="-"){o=A.jK(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}if(p==="+")return A.mv(a,s)
if(p==="*")throw A.d(A.da(n))
if(v.leafTags[n]===true){o=A.jK(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}else return A.mv(a,s)},
mv(a,b){var s=Object.getPrototypeOf(a)
Object.defineProperty(s,v.dispatchPropertyName,{value:J.kA(b,s,null,null),enumerable:false,writable:true,configurable:true})
return b},
jK(a){return J.kA(a,!1,null,!!a.$iai)},
qg(a,b,c){var s=b.prototype
if(v.leafTags[a]===true)return A.jK(s)
else return J.kA(s,c,null,null)},
q9(){if(!0===$.kz)return
$.kz=!0
A.qa()},
qa(){var s,r,q,p,o,n,m,l
$.jA=Object.create(null)
$.jI=Object.create(null)
A.q8()
s=v.interceptorsByTag
r=Object.getOwnPropertyNames(s)
if(typeof window!="undefined"){window
q=function(){}
for(p=0;p<r.length;++p){o=r[p]
n=$.mx.$1(o)
if(n!=null){m=A.qg(o,s[o],n)
if(m!=null){Object.defineProperty(n,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
q.prototype=n}}}}for(p=0;p<r.length;++p){o=r[p]
if(/^[A-Za-z_]/.test(o)){l=s[o]
s["!"+o]=l
s["~"+o]=l
s["-"+o]=l
s["+"+o]=l
s["*"+o]=l}}},
q8(){var s,r,q,p,o,n,m=B.aQ()
m=A.ck(B.aR,A.ck(B.aS,A.ck(B.a2,A.ck(B.a2,A.ck(B.aT,A.ck(B.aU,A.ck(B.aV(B.a1),m)))))))
if(typeof dartNativeDispatchHooksTransformer!="undefined"){s=dartNativeDispatchHooksTransformer
if(typeof s=="function")s=[s]
if(s.constructor==Array)for(r=0;r<s.length;++r){q=s[r]
if(typeof q=="function")m=q(m)||m}}p=m.getTag
o=m.getUnknownTag
n=m.prototypeForTag
$.ms=new A.jF(p)
$.mj=new A.jG(o)
$.mx=new A.jH(n)},
ck(a,b){return a(b)||b},
nF(a,b,c,d,e,f){var s=b?"m":"",r=c?"":"i",q=d?"u":"",p=e?"s":"",o=f?"g":"",n=function(g,h){try{return new RegExp(g,h)}catch(m){return m}}(a,s+r+q+p+o)
if(n instanceof RegExp)return n
throw A.d(A.h4("Illegal RegExp pattern ("+String(n)+")",a,null))},
qj(a){if(/[[\]{}()*+?.\\^$|]/.test(a))return a.replace(/[[\]{}()*+?.\\^$|]/g,"\\$&")
return a},
bX:function bX(){},
ct:function ct(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.$ti=d},
fW:function fW(a){this.a=a},
dl:function dl(a,b){this.a=a
this.$ti=b},
cC:function cC(a,b){this.a=a
this.$ti=b},
h5:function h5(a){this.a=a},
i6:function i6(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
cY:function cY(a,b){this.a=a
this.b=b},
ew:function ew(a,b,c){this.a=a
this.b=b
this.c=c},
f9:function f9(a){this.a=a},
hH:function hH(a){this.a=a},
cw:function cw(a,b){this.a=a
this.b=b},
dA:function dA(a){this.a=a
this.b=null},
b9:function b9(){},
dV:function dV(){},
dW:function dW(){},
f4:function f4(){},
eZ:function eZ(){},
bU:function bU(a,b){this.a=a
this.b=b},
eY:function eY(a){this.a=a},
fi:function fi(a){this.a=a},
ap:function ap(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
hw:function hw(a){this.a=a},
hv:function hv(a){this.a=a},
hy:function hy(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
aA:function aA(a,b){this.a=a
this.$ti=b},
bE:function bE(a,b,c){var _=this
_.a=a
_.b=b
_.d=_.c=null
_.$ti=c},
jF:function jF(a){this.a=a},
jG:function jG(a){this.a=a},
jH:function jH(a){this.a=a},
et:function et(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
c(a){return A.F(A.hx(a))},
mz(a){return A.F(A.nG(a))},
ar(a){var s=new A.iN(a)
return s.b=s},
iN:function iN(a){this.a=a
this.b=null},
bO(a,b,c){},
b_(a){return a},
nK(a){return new Float32Array(a)},
nL(a,b,c){A.bO(a,b,c)
c=B.a.F(a.byteLength-b,4)
return new Float32Array(a,b,c)},
nM(a){return new Int32Array(a)},
li(a){return new Int8Array(a)},
nN(a){return new Uint16Array(a)},
nO(a){return new Uint32Array(a)},
k4(a,b,c){A.bO(a,b,c)
c=B.a.F(a.byteLength-b,4)
return new Uint32Array(a,b,c)},
hE(a){return new Uint8Array(a)},
z(a,b,c){A.bO(a,b,c)
return c==null?new Uint8Array(a,b):new Uint8Array(a,b,c)},
aZ(a,b,c){if(a>>>0!==a||a>=c)throw A.d(A.cm(b,a))},
aD(a,b,c){var s
if(!(a>>>0!==a))if(b==null)s=a>c
else s=b>>>0!==b||a>b||b>c
else s=!0
if(s)throw A.d(A.pZ(a,b,c))
if(b==null)return c
return b},
cV:function cV(){},
N:function N(){},
U:function U(){},
bd:function bd(){},
aj:function aj(){},
eD:function eD(){},
eE:function eE(){},
eF:function eF(){},
eG:function eG(){},
eH:function eH(){},
eI:function eI(){},
cW:function cW(){},
cX:function cX(){},
bG:function bG(){},
du:function du(){},
dv:function dv(){},
dw:function dw(){},
dx:function dx(){},
ly(a,b){var s=b.c
return s==null?b.c=A.kq(a,b.y,!0):s},
lx(a,b){var s=b.c
return s==null?b.c=A.dF(a,"ax",[b.y]):s},
lz(a){var s=a.x
if(s===6||s===7||s===8)return A.lz(a.y)
return s===11||s===12},
nV(a){return a.at},
b1(a){return A.fA(v.typeUniverse,a,!1)},
bq(a,b,a0,a1){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=b.x
switch(c){case 5:case 1:case 2:case 3:case 4:return b
case 6:s=b.y
r=A.bq(a,s,a0,a1)
if(r===s)return b
return A.m1(a,r,!0)
case 7:s=b.y
r=A.bq(a,s,a0,a1)
if(r===s)return b
return A.kq(a,r,!0)
case 8:s=b.y
r=A.bq(a,s,a0,a1)
if(r===s)return b
return A.m0(a,r,!0)
case 9:q=b.z
p=A.dM(a,q,a0,a1)
if(p===q)return b
return A.dF(a,b.y,p)
case 10:o=b.y
n=A.bq(a,o,a0,a1)
m=b.z
l=A.dM(a,m,a0,a1)
if(n===o&&l===m)return b
return A.ko(a,n,l)
case 11:k=b.y
j=A.bq(a,k,a0,a1)
i=b.z
h=A.pL(a,i,a0,a1)
if(j===k&&h===i)return b
return A.m_(a,j,h)
case 12:g=b.z
a1+=g.length
f=A.dM(a,g,a0,a1)
o=b.y
n=A.bq(a,o,a0,a1)
if(f===g&&n===o)return b
return A.kp(a,n,f,!0)
case 13:e=b.y
if(e<a1)return b
d=a0[e-a1]
if(d==null)return b
return d
default:throw A.d(A.fK("Attempted to substitute unexpected RTI kind "+c))}},
dM(a,b,c,d){var s,r,q,p,o=b.length,n=A.jn(o)
for(s=!1,r=0;r<o;++r){q=b[r]
p=A.bq(a,q,c,d)
if(p!==q)s=!0
n[r]=p}return s?n:b},
pM(a,b,c,d){var s,r,q,p,o,n,m=b.length,l=A.jn(m)
for(s=!1,r=0;r<m;r+=3){q=b[r]
p=b[r+1]
o=b[r+2]
n=A.bq(a,o,c,d)
if(n!==o)s=!0
l.splice(r,3,q,p,n)}return s?l:b},
pL(a,b,c,d){var s,r=b.a,q=A.dM(a,r,c,d),p=b.b,o=A.dM(a,p,c,d),n=b.c,m=A.pM(a,n,c,d)
if(q===r&&o===p&&m===n)return b
s=new A.fo()
s.a=q
s.b=o
s.c=m
return s},
b(a,b){a[v.arrayRti]=b
return a},
ml(a){var s=a.$S
if(s!=null){if(typeof s=="number")return A.q5(s)
return a.$S()}return null},
mt(a,b){var s
if(A.lz(b))if(a instanceof A.b9){s=A.ml(a)
if(s!=null)return s}return A.S(a)},
S(a){var s
if(a instanceof A.t){s=a.$ti
return s!=null?s:A.ku(a)}if(Array.isArray(a))return A.a5(a)
return A.ku(J.cn(a))},
a5(a){var s=a[v.arrayRti],r=t.dG
if(s==null)return r
if(s.constructor!==r.constructor)return r
return s},
w(a){var s=a.$ti
return s!=null?s:A.ku(a)},
ku(a){var s=a.constructor,r=s.$ccache
if(r!=null)return r
return A.pv(a,s)},
pv(a,b){var s=a instanceof A.b9?a.__proto__.__proto__.constructor:b,r=A.pd(v.typeUniverse,s.name)
b.$ccache=r
return r},
q5(a){var s,r=v.types,q=r[a]
if(typeof q=="string"){s=A.fA(v.typeUniverse,q,!1)
r[a]=s
return s}return q},
q4(a){var s=a instanceof A.b9?A.ml(a):null
return A.mo(s==null?A.S(a):s)},
mo(a){var s,r,q,p=a.w
if(p!=null)return p
s=a.at
r=s.replace(/\*/g,"")
if(r===s)return a.w=new A.dD(a)
q=A.fA(v.typeUniverse,r,!0)
p=q.w
return a.w=p==null?q.w=new A.dD(q):p},
b4(a){return A.mo(A.fA(v.typeUniverse,a,!1))},
pu(a){var s,r,q,p,o=this
if(o===t.K)return A.ci(o,a,A.pz)
if(!A.b2(o))if(!(o===t._))s=!1
else s=!0
else s=!0
if(s)return A.ci(o,a,A.pC)
s=o.x
r=s===6?o.y:o
if(r===t.p)q=A.jr
else if(r===t.dx||r===t.cZ)q=A.py
else if(r===t.N)q=A.pA
else q=r===t.v?A.dJ:null
if(q!=null)return A.ci(o,a,q)
if(r.x===9){p=r.y
if(r.z.every(A.qd)){o.r="$i"+p
if(p==="h")return A.ci(o,a,A.px)
return A.ci(o,a,A.pB)}}else if(s===7)return A.ci(o,a,A.ps)
return A.ci(o,a,A.pq)},
ci(a,b,c){a.b=c
return a.b(b)},
pt(a){var s,r=this,q=A.pp
if(!A.b2(r))if(!(r===t._))s=!1
else s=!0
else s=!0
if(s)q=A.pj
else if(r===t.K)q=A.pi
else{s=A.dO(r)
if(s)q=A.pr}r.a=q
return r.a(a)},
js(a){var s,r=a.x
if(!A.b2(a))if(!(a===t._))if(!(a===t.eK))if(r!==7)s=r===8&&A.js(a.y)||a===t.P||a===t.u
else s=!0
else s=!0
else s=!0
else s=!0
return s},
pq(a){var s=this
if(a==null)return A.js(s)
return A.M(v.typeUniverse,A.mt(a,s),null,s,null)},
ps(a){if(a==null)return!0
return this.y.b(a)},
pB(a){var s,r=this
if(a==null)return A.js(r)
s=r.r
if(a instanceof A.t)return!!a[s]
return!!J.cn(a)[s]},
px(a){var s,r=this
if(a==null)return A.js(r)
if(typeof a!="object")return!1
if(Array.isArray(a))return!0
s=r.r
if(a instanceof A.t)return!!a[s]
return!!J.cn(a)[s]},
pp(a){var s,r=this
if(a==null){s=A.dO(r)
if(s)return a}else if(r.b(a))return a
A.ma(a,r)},
pr(a){var s=this
if(a==null)return a
else if(s.b(a))return a
A.ma(a,s)},
ma(a,b){throw A.d(A.p3(A.lS(a,A.mt(a,b),A.al(b,null))))},
lS(a,b,c){var s=A.cv(a)
return s+": type '"+A.al(b==null?A.S(a):b,null)+"' is not a subtype of type '"+c+"'"},
p3(a){return new A.dE("TypeError: "+a)},
a4(a,b){return new A.dE("TypeError: "+A.lS(a,null,b))},
pz(a){return a!=null},
pi(a){if(a!=null)return a
throw A.d(A.a4(a,"Object"))},
pC(a){return!0},
pj(a){return a},
dJ(a){return!0===a||!1===a},
m5(a){if(!0===a)return!0
if(!1===a)return!1
throw A.d(A.a4(a,"bool"))},
rN(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.d(A.a4(a,"bool"))},
rM(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.d(A.a4(a,"bool?"))},
pg(a){if(typeof a=="number")return a
throw A.d(A.a4(a,"double"))},
rP(a){if(typeof a=="number")return a
if(a==null)return a
throw A.d(A.a4(a,"double"))},
rO(a){if(typeof a=="number")return a
if(a==null)return a
throw A.d(A.a4(a,"double?"))},
jr(a){return typeof a=="number"&&Math.floor(a)===a},
o(a){if(typeof a=="number"&&Math.floor(a)===a)return a
throw A.d(A.a4(a,"int"))},
rQ(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.d(A.a4(a,"int"))},
m6(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.d(A.a4(a,"int?"))},
py(a){return typeof a=="number"},
ph(a){if(typeof a=="number")return a
throw A.d(A.a4(a,"num"))},
rS(a){if(typeof a=="number")return a
if(a==null)return a
throw A.d(A.a4(a,"num"))},
rR(a){if(typeof a=="number")return a
if(a==null)return a
throw A.d(A.a4(a,"num?"))},
pA(a){return typeof a=="string"},
a_(a){if(typeof a=="string")return a
throw A.d(A.a4(a,"String"))},
rT(a){if(typeof a=="string")return a
if(a==null)return a
throw A.d(A.a4(a,"String"))},
kr(a){if(typeof a=="string")return a
if(a==null)return a
throw A.d(A.a4(a,"String?"))},
pI(a,b){var s,r,q
for(s="",r="",q=0;q<a.length;++q,r=", ")s+=r+A.al(a[q],b)
return s},
mb(a4,a5,a6){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3=", "
if(a6!=null){s=a6.length
if(a5==null){a5=A.b([],t.s)
r=null}else r=a5.length
q=a5.length
for(p=s;p>0;--p)B.b.A(a5,"T"+(q+p))
for(o=t.X,n=t._,m="<",l="",p=0;p<s;++p,l=a3){k=a5.length
j=k-1-p
if(!(j>=0))return A.a(a5,j)
m=B.d.bq(m+l,a5[j])
i=a6[p]
h=i.x
if(!(h===2||h===3||h===4||h===5||i===o))if(!(i===n))k=!1
else k=!0
else k=!0
if(!k)m+=" extends "+A.al(i,a5)}m+=">"}else{m=""
r=null}o=a4.y
g=a4.z
f=g.a
e=f.length
d=g.b
c=d.length
b=g.c
a=b.length
a0=A.al(o,a5)
for(a1="",a2="",p=0;p<e;++p,a2=a3)a1+=a2+A.al(f[p],a5)
if(c>0){a1+=a2+"["
for(a2="",p=0;p<c;++p,a2=a3)a1+=a2+A.al(d[p],a5)
a1+="]"}if(a>0){a1+=a2+"{"
for(a2="",p=0;p<a;p+=3,a2=a3){a1+=a2
if(b[p+1])a1+="required "
a1+=A.al(b[p+2],a5)+" "+b[p]}a1+="}"}if(r!=null){a5.toString
a5.length=r}return m+"("+a1+") => "+a0},
al(a,b){var s,r,q,p,o,n,m,l=a.x
if(l===5)return"erased"
if(l===2)return"dynamic"
if(l===3)return"void"
if(l===1)return"Never"
if(l===4)return"any"
if(l===6){s=A.al(a.y,b)
return s}if(l===7){r=a.y
s=A.al(r,b)
q=r.x
return(q===11||q===12?"("+s+")":s)+"?"}if(l===8)return"FutureOr<"+A.al(a.y,b)+">"
if(l===9){p=A.pN(a.y)
o=a.z
return o.length>0?p+("<"+A.pI(o,b)+">"):p}if(l===11)return A.mb(a,b,null)
if(l===12)return A.mb(a.y,b,a.z)
if(l===13){n=a.y
m=b.length
n=m-1-n
if(!(n>=0&&n<m))return A.a(b,n)
return b[n]}return"?"},
pN(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
pe(a,b){var s=a.tR[b]
for(;typeof s=="string";)s=a.tR[s]
return s},
pd(a,b){var s,r,q,p,o,n=a.eT,m=n[b]
if(m==null)return A.fA(a,b,!1)
else if(typeof m=="number"){s=m
r=A.dG(a,5,"#")
q=A.jn(s)
for(p=0;p<s;++p)q[p]=r
o=A.dF(a,b,q)
n[b]=o
return o}else return m},
pb(a,b){return A.m3(a.tR,b)},
pa(a,b){return A.m3(a.eT,b)},
fA(a,b,c){var s,r=a.eC,q=r.get(b)
if(q!=null)return q
s=A.lZ(A.lX(a,null,b,c))
r.set(b,s)
return s},
jk(a,b,c){var s,r,q=b.Q
if(q==null)q=b.Q=new Map()
s=q.get(c)
if(s!=null)return s
r=A.lZ(A.lX(a,b,c,!0))
q.set(c,r)
return r},
pc(a,b,c){var s,r,q,p=b.as
if(p==null)p=b.as=new Map()
s=c.at
r=p.get(s)
if(r!=null)return r
q=A.ko(a,b,c.x===10?c.z:[c])
p.set(s,q)
return q},
bp(a,b){b.a=A.pt
b.b=A.pu
return b},
dG(a,b,c){var s,r,q=a.eC.get(c)
if(q!=null)return q
s=new A.aB(null,null)
s.x=b
s.at=c
r=A.bp(a,s)
a.eC.set(c,r)
return r},
m1(a,b,c){var s,r=b.at+"*",q=a.eC.get(r)
if(q!=null)return q
s=A.p8(a,b,r,c)
a.eC.set(r,s)
return s},
p8(a,b,c,d){var s,r,q
if(d){s=b.x
if(!A.b2(b))r=b===t.P||b===t.u||s===7||s===6
else r=!0
if(r)return b}q=new A.aB(null,null)
q.x=6
q.y=b
q.at=c
return A.bp(a,q)},
kq(a,b,c){var s,r=b.at+"?",q=a.eC.get(r)
if(q!=null)return q
s=A.p7(a,b,r,c)
a.eC.set(r,s)
return s},
p7(a,b,c,d){var s,r,q,p
if(d){s=b.x
if(!A.b2(b))if(!(b===t.P||b===t.u))if(s!==7)r=s===8&&A.dO(b.y)
else r=!0
else r=!0
else r=!0
if(r)return b
else if(s===1||b===t.eK)return t.P
else if(s===6){q=b.y
if(q.x===8&&A.dO(q.y))return q
else return A.ly(a,b)}}p=new A.aB(null,null)
p.x=7
p.y=b
p.at=c
return A.bp(a,p)},
m0(a,b,c){var s,r=b.at+"/",q=a.eC.get(r)
if(q!=null)return q
s=A.p5(a,b,r,c)
a.eC.set(r,s)
return s},
p5(a,b,c,d){var s,r,q
if(d){s=b.x
if(!A.b2(b))if(!(b===t._))r=!1
else r=!0
else r=!0
if(r||b===t.K)return b
else if(s===1)return A.dF(a,"ax",[b])
else if(b===t.P||b===t.u)return t.gK}q=new A.aB(null,null)
q.x=8
q.y=b
q.at=c
return A.bp(a,q)},
p9(a,b){var s,r,q=""+b+"^",p=a.eC.get(q)
if(p!=null)return p
s=new A.aB(null,null)
s.x=13
s.y=b
s.at=q
r=A.bp(a,s)
a.eC.set(q,r)
return r},
fz(a){var s,r,q,p=a.length
for(s="",r="",q=0;q<p;++q,r=",")s+=r+a[q].at
return s},
p4(a){var s,r,q,p,o,n=a.length
for(s="",r="",q=0;q<n;q+=3,r=","){p=a[q]
o=a[q+1]?"!":":"
s+=r+p+o+a[q+2].at}return s},
dF(a,b,c){var s,r,q,p=b
if(c.length>0)p+="<"+A.fz(c)+">"
s=a.eC.get(p)
if(s!=null)return s
r=new A.aB(null,null)
r.x=9
r.y=b
r.z=c
if(c.length>0)r.c=c[0]
r.at=p
q=A.bp(a,r)
a.eC.set(p,q)
return q},
ko(a,b,c){var s,r,q,p,o,n
if(b.x===10){s=b.y
r=b.z.concat(c)}else{r=c
s=b}q=s.at+(";<"+A.fz(r)+">")
p=a.eC.get(q)
if(p!=null)return p
o=new A.aB(null,null)
o.x=10
o.y=s
o.z=r
o.at=q
n=A.bp(a,o)
a.eC.set(q,n)
return n},
m_(a,b,c){var s,r,q,p,o,n=b.at,m=c.a,l=m.length,k=c.b,j=k.length,i=c.c,h=i.length,g="("+A.fz(m)
if(j>0){s=l>0?",":""
g+=s+"["+A.fz(k)+"]"}if(h>0){s=l>0?",":""
g+=s+"{"+A.p4(i)+"}"}r=n+(g+")")
q=a.eC.get(r)
if(q!=null)return q
p=new A.aB(null,null)
p.x=11
p.y=b
p.z=c
p.at=r
o=A.bp(a,p)
a.eC.set(r,o)
return o},
kp(a,b,c,d){var s,r=b.at+("<"+A.fz(c)+">"),q=a.eC.get(r)
if(q!=null)return q
s=A.p6(a,b,c,r,d)
a.eC.set(r,s)
return s},
p6(a,b,c,d,e){var s,r,q,p,o,n,m,l
if(e){s=c.length
r=A.jn(s)
for(q=0,p=0;p<s;++p){o=c[p]
if(o.x===1){r[p]=o;++q}}if(q>0){n=A.bq(a,b,r,0)
m=A.dM(a,c,r,0)
return A.kp(a,n,m,c!==m)}}l=new A.aB(null,null)
l.x=12
l.y=b
l.z=c
l.at=d
return A.bp(a,l)},
lX(a,b,c,d){return{u:a,e:b,r:c,s:[],p:0,n:d}},
lZ(a){var s,r,q,p,o,n,m,l,k,j,i,h=a.r,g=a.s
for(s=h.length,r=0;r<s;){q=h.charCodeAt(r)
if(q>=48&&q<=57)r=A.oZ(r+1,q,h,g)
else if((((q|32)>>>0)-97&65535)<26||q===95||q===36)r=A.lY(a,r,h,g,!1)
else if(q===46)r=A.lY(a,r,h,g,!0)
else{++r
switch(q){case 44:break
case 58:g.push(!1)
break
case 33:g.push(!0)
break
case 59:g.push(A.bn(a.u,a.e,g.pop()))
break
case 94:g.push(A.p9(a.u,g.pop()))
break
case 35:g.push(A.dG(a.u,5,"#"))
break
case 64:g.push(A.dG(a.u,2,"@"))
break
case 126:g.push(A.dG(a.u,3,"~"))
break
case 60:g.push(a.p)
a.p=g.length
break
case 62:p=a.u
o=g.splice(a.p)
A.km(a.u,a.e,o)
a.p=g.pop()
n=g.pop()
if(typeof n=="string")g.push(A.dF(p,n,o))
else{m=A.bn(p,a.e,n)
switch(m.x){case 11:g.push(A.kp(p,m,o,a.n))
break
default:g.push(A.ko(p,m,o))
break}}break
case 38:A.p_(a,g)
break
case 42:p=a.u
g.push(A.m1(p,A.bn(p,a.e,g.pop()),a.n))
break
case 63:p=a.u
g.push(A.kq(p,A.bn(p,a.e,g.pop()),a.n))
break
case 47:p=a.u
g.push(A.m0(p,A.bn(p,a.e,g.pop()),a.n))
break
case 40:g.push(a.p)
a.p=g.length
break
case 41:p=a.u
l=new A.fo()
k=p.sEA
j=p.sEA
n=g.pop()
if(typeof n=="number")switch(n){case-1:k=g.pop()
break
case-2:j=g.pop()
break
default:g.push(n)
break}else g.push(n)
o=g.splice(a.p)
A.km(a.u,a.e,o)
a.p=g.pop()
l.a=o
l.b=k
l.c=j
g.push(A.m_(p,A.bn(p,a.e,g.pop()),l))
break
case 91:g.push(a.p)
a.p=g.length
break
case 93:o=g.splice(a.p)
A.km(a.u,a.e,o)
a.p=g.pop()
g.push(o)
g.push(-1)
break
case 123:g.push(a.p)
a.p=g.length
break
case 125:o=g.splice(a.p)
A.p1(a.u,a.e,o)
a.p=g.pop()
g.push(o)
g.push(-2)
break
default:throw"Bad character "+q}}}i=g.pop()
return A.bn(a.u,a.e,i)},
oZ(a,b,c,d){var s,r,q=b-48
for(s=c.length;a<s;++a){r=c.charCodeAt(a)
if(!(r>=48&&r<=57))break
q=q*10+(r-48)}d.push(q)
return a},
lY(a,b,c,d,e){var s,r,q,p,o,n,m=b+1
for(s=c.length;m<s;++m){r=c.charCodeAt(m)
if(r===46){if(e)break
e=!0}else{if(!((((r|32)>>>0)-97&65535)<26||r===95||r===36))q=r>=48&&r<=57
else q=!0
if(!q)break}}p=c.substring(b,m)
if(e){s=a.u
o=a.e
if(o.x===10)o=o.y
n=A.pe(s,o.y)[p]
if(n==null)A.F('No "'+p+'" in "'+A.nV(o)+'"')
d.push(A.jk(s,o,n))}else d.push(p)
return m},
p_(a,b){var s=b.pop()
if(0===s){b.push(A.dG(a.u,1,"0&"))
return}if(1===s){b.push(A.dG(a.u,4,"1&"))
return}throw A.d(A.fK("Unexpected extended operation "+A.v(s)))},
bn(a,b,c){if(typeof c=="string")return A.dF(a,c,a.sEA)
else if(typeof c=="number")return A.p0(a,b,c)
else return c},
km(a,b,c){var s,r=c.length
for(s=0;s<r;++s)c[s]=A.bn(a,b,c[s])},
p1(a,b,c){var s,r=c.length
for(s=2;s<r;s+=3)c[s]=A.bn(a,b,c[s])},
p0(a,b,c){var s,r,q=b.x
if(q===10){if(c===0)return b.y
s=b.z
r=s.length
if(c<=r)return s[c-1]
c-=r
b=b.y
q=b.x}else if(c===0)return b
if(q!==9)throw A.d(A.fK("Indexed base must be an interface type"))
s=b.z
if(c<=s.length)return s[c-1]
throw A.d(A.fK("Bad index "+c+" for "+b.u(0)))},
M(a,b,c,d,e){var s,r,q,p,o,n,m,l,k,j
if(b===d)return!0
if(!A.b2(d))if(!(d===t._))s=!1
else s=!0
else s=!0
if(s)return!0
r=b.x
if(r===4)return!0
if(A.b2(b))return!1
if(b.x!==1)s=!1
else s=!0
if(s)return!0
q=r===13
if(q)if(A.M(a,c[b.y],c,d,e))return!0
p=d.x
s=b===t.P||b===t.u
if(s){if(p===8)return A.M(a,b,c,d.y,e)
return d===t.P||d===t.u||p===7||p===6}if(d===t.K){if(r===8)return A.M(a,b.y,c,d,e)
if(r===6)return A.M(a,b.y,c,d,e)
return r!==7}if(r===6)return A.M(a,b.y,c,d,e)
if(p===6){s=A.ly(a,d)
return A.M(a,b,c,s,e)}if(r===8){if(!A.M(a,b.y,c,d,e))return!1
return A.M(a,A.lx(a,b),c,d,e)}if(r===7){s=A.M(a,t.P,c,d,e)
return s&&A.M(a,b.y,c,d,e)}if(p===8){if(A.M(a,b,c,d.y,e))return!0
return A.M(a,b,c,A.lx(a,d),e)}if(p===7){s=A.M(a,b,c,t.P,e)
return s||A.M(a,b,c,d.y,e)}if(q)return!1
s=r!==11
if((!s||r===12)&&d===t.Y)return!0
if(p===12){if(b===t.dY)return!0
if(r!==12)return!1
o=b.z
n=d.z
m=o.length
if(m!==n.length)return!1
c=c==null?o:o.concat(c)
e=e==null?n:n.concat(e)
for(l=0;l<m;++l){k=o[l]
j=n[l]
if(!A.M(a,k,c,j,e)||!A.M(a,j,e,k,c))return!1}return A.mc(a,b.y,c,d.y,e)}if(p===11){if(b===t.dY)return!0
if(s)return!1
return A.mc(a,b,c,d,e)}if(r===9){if(p!==9)return!1
return A.pw(a,b,c,d,e)}return!1},
mc(a3,a4,a5,a6,a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2
if(!A.M(a3,a4.y,a5,a6.y,a7))return!1
s=a4.z
r=a6.z
q=s.a
p=r.a
o=q.length
n=p.length
if(o>n)return!1
m=n-o
l=s.b
k=r.b
j=l.length
i=k.length
if(o+j<n+i)return!1
for(h=0;h<o;++h){g=q[h]
if(!A.M(a3,p[h],a7,g,a5))return!1}for(h=0;h<m;++h){g=l[h]
if(!A.M(a3,p[o+h],a7,g,a5))return!1}for(h=0;h<i;++h){g=l[m+h]
if(!A.M(a3,k[h],a7,g,a5))return!1}f=s.c
e=r.c
d=f.length
c=e.length
for(b=0,a=0;a<c;a+=3){a0=e[a]
for(;!0;){if(b>=d)return!1
a1=f[b]
b+=3
if(a0<a1)return!1
a2=f[b-2]
if(a1<a0){if(a2)return!1
continue}g=e[a+1]
if(a2&&!g)return!1
g=f[b-1]
if(!A.M(a3,e[a+2],a7,g,a5))return!1
break}}for(;b<d;){if(f[b+1])return!1
b+=3}return!0},
pw(a,b,c,d,e){var s,r,q,p,o,n,m,l=b.y,k=d.y
for(;l!==k;){s=a.tR[l]
if(s==null)return!1
if(typeof s=="string"){l=s
continue}r=s[k]
if(r==null)return!1
q=r.length
p=q>0?new Array(q):v.typeUniverse.sEA
for(o=0;o<q;++o)p[o]=A.jk(a,b,r[o])
return A.m4(a,p,null,c,d.z,e)}n=b.z
m=d.z
return A.m4(a,n,null,c,m,e)},
m4(a,b,c,d,e,f){var s,r,q,p=b.length
for(s=0;s<p;++s){r=b[s]
q=e[s]
if(!A.M(a,r,d,q,f))return!1}return!0},
dO(a){var s,r=a.x
if(!(a===t.P||a===t.u))if(!A.b2(a))if(r!==7)if(!(r===6&&A.dO(a.y)))s=r===8&&A.dO(a.y)
else s=!0
else s=!0
else s=!0
else s=!0
return s},
qd(a){var s
if(!A.b2(a))if(!(a===t._))s=!1
else s=!0
else s=!0
return s},
b2(a){var s=a.x
return s===2||s===3||s===4||s===5||a===t.X},
m3(a,b){var s,r,q=Object.keys(b),p=q.length
for(s=0;s<p;++s){r=q[s]
a[r]=b[r]}},
jn(a){return a>0?new Array(a):v.typeUniverse.sEA},
aB:function aB(a,b){var _=this
_.a=a
_.b=b
_.w=_.r=_.c=null
_.x=0
_.at=_.as=_.Q=_.z=_.y=null},
fo:function fo(){this.c=this.b=this.a=null},
dD:function dD(a){this.a=a},
fn:function fn(){},
dE:function dE(a){this.a=a},
oP(){var s,r,q={}
if(self.scheduleImmediate!=null)return A.pR()
if(self.MutationObserver!=null&&self.document!=null){s=self.document.createElement("div")
r=self.document.createElement("span")
q.a=null
new self.MutationObserver(A.bQ(new A.iI(q),1)).observe(s,{childList:true})
return new A.iH(q,s,r)}else if(self.setImmediate!=null)return A.pS()
return A.pT()},
oQ(a){self.scheduleImmediate(A.bQ(new A.iJ(t.M.a(a)),0))},
oR(a){self.setImmediate(A.bQ(new A.iK(t.M.a(a)),0))},
oS(a){t.M.a(a)
A.p2(0,a)},
p2(a,b){var s=new A.ji()
s.fK(a,b)
return s},
md(a){return new A.fj(new A.L($.C,a.l("L<0>")),a.l("fj<0>"))},
m9(a,b){a.$2(0,null)
b.b=!0
return b.a},
ks(a,b){A.pk(a,b)},
m8(a,b){b.cj(a)},
m7(a,b){b.d3(A.a0(a),A.an(a))},
pk(a,b){var s,r,q=new A.jp(b),p=new A.jq(b)
if(a instanceof A.L)a.en(q,p,t.z)
else{s=t.z
if(t.c.b(a))a.da(q,p,s)
else{r=new A.L($.C,t.d)
r.a=8
r.c=a
r.en(q,p,s)}}},
mi(a){var s=function(b,c){return function(d,e){while(true)try{b(d,e)
break}catch(r){e=r
d=c}}}(a,1)
return $.C.eU(new A.jv(s),t.q,t.p,t.z)},
ru(a){return new A.cg(a,1)},
lU(){return B.hY},
lV(a){return new A.cg(a,3)},
me(a,b){return new A.dC(a,b.l("dC<0>"))},
fL(a,b){var s=A.cl(a,"error",t.K)
return new A.cr(s,b==null?A.kN(a):b)},
kN(a){var s
if(t.Q.b(a)){s=a.gbY()
if(s!=null)return s}return B.aY},
kj(a,b){var s,r,q
for(s=t.d;r=a.a,(r&4)!==0;)a=s.a(a.c)
if((r&24)!==0){q=b.cc()
b.cA(a)
A.cf(b,q)}else{q=t.F.a(b.c)
b.a=b.a&1|4
b.c=a
a.ec(q)}},
cf(a,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c={},b=c.a=a
for(s=t.n,r=t.F,q=t.c;!0;){p={}
o=b.a
n=(o&16)===0
m=!n
if(a0==null){if(m&&(o&1)===0){l=s.a(b.c)
A.jt(l.a,l.b)}return}p.a=a0
k=a0.a
for(b=a0;k!=null;b=k,k=j){b.a=null
A.cf(c.a,b)
p.a=k
j=k.a}o=c.a
i=o.c
p.b=m
p.c=i
if(n){h=b.c
h=(h&1)!==0||(h&15)===8}else h=!0
if(h){g=b.b.b
if(m){o=o.b===g
o=!(o||o)}else o=!1
if(o){s.a(i)
A.jt(i.a,i.b)
return}f=$.C
if(f!==g)$.C=g
else f=null
b=b.c
if((b&15)===8)new A.j2(p,c,m).$0()
else if(n){if((b&1)!==0)new A.j1(p,i).$0()}else if((b&2)!==0)new A.j0(c,p).$0()
if(f!=null)$.C=f
b=p.c
if(q.b(b)){o=p.a.$ti
o=o.l("ax<2>").b(b)||!o.z[1].b(b)}else o=!1
if(o){q.a(b)
e=p.a.b
if((b.a&24)!==0){d=r.a(e.c)
e.c=null
a0=e.cd(d)
e.a=b.a&30|e.a&1
e.c=b.c
c.a=b
continue}else A.kj(b,e)
return}}e=p.a.b
d=r.a(e.c)
e.c=null
a0=e.cd(d)
b=p.b
o=p.c
if(!b){e.$ti.c.a(o)
e.a=8
e.c=o}else{s.a(o)
e.a=e.a&1|16
e.c=o}c.a=e
b=e}},
pG(a,b){var s
if(t.C.b(a))return b.eU(a,t.z,t.K,t.l)
s=t.E
if(s.b(a))return s.a(a)
throw A.d(A.bS(a,"onError",u.b))},
pF(){var s,r
for(s=$.cj;s!=null;s=$.cj){$.dL=null
r=s.b
$.cj=r
if(r==null)$.dK=null
s.a.$0()}},
pK(){$.kv=!0
try{A.pF()}finally{$.dL=null
$.kv=!1
if($.cj!=null)$.kD().$1(A.mk())}},
mh(a){var s=new A.fk(a),r=$.dK
if(r==null){$.cj=$.dK=s
if(!$.kv)$.kD().$1(A.mk())}else $.dK=r.b=s},
pJ(a){var s,r,q,p=$.cj
if(p==null){A.mh(a)
$.dL=$.dK
return}s=new A.fk(a)
r=$.dL
if(r==null){s.b=p
$.cj=$.dL=s}else{q=r.b
s.b=q
$.dL=r.b=s
if(q==null)$.dK=s}},
qk(a){var s,r=null,q=$.C
if(B.h===q){A.bP(r,r,B.h,a)
return}s=!1
if(s){A.bP(r,r,q,t.M.a(a))
return}A.bP(r,r,q,t.M.a(q.eA(a)))},
r9(a,b){A.cl(a,"stream",t.K)
return new A.fu(b.l("fu<0>"))},
jt(a,b){A.pJ(new A.ju(a,b))},
mf(a,b,c,d,e){var s,r=$.C
if(r===c)return d.$0()
$.C=c
s=r
try{r=d.$0()
return r}finally{$.C=s}},
mg(a,b,c,d,e,f,g){var s,r=$.C
if(r===c)return d.$1(e)
$.C=c
s=r
try{r=d.$1(e)
return r}finally{$.C=s}},
pH(a,b,c,d,e,f,g,h,i){var s,r=$.C
if(r===c)return d.$2(e,f)
$.C=c
s=r
try{r=d.$2(e,f)
return r}finally{$.C=s}},
bP(a,b,c,d){t.M.a(d)
if(B.h!==c)d=c.eA(d)
A.mh(d)},
iI:function iI(a){this.a=a},
iH:function iH(a,b,c){this.a=a
this.b=b
this.c=c},
iJ:function iJ(a){this.a=a},
iK:function iK(a){this.a=a},
ji:function ji(){},
jj:function jj(a,b){this.a=a
this.b=b},
fj:function fj(a,b){this.a=a
this.b=!1
this.$ti=b},
jp:function jp(a){this.a=a},
jq:function jq(a){this.a=a},
jv:function jv(a){this.a=a},
cg:function cg(a,b){this.a=a
this.b=b},
bo:function bo(a,b){var _=this
_.a=a
_.d=_.c=_.b=null
_.$ti=b},
dC:function dC(a,b){this.a=a
this.$ti=b},
cr:function cr(a,b){this.a=a
this.b=b},
fm:function fm(){},
bM:function bM(a,b){this.a=a
this.$ti=b},
aY:function aY(a,b,c,d,e){var _=this
_.a=null
_.b=a
_.c=b
_.d=c
_.e=d
_.$ti=e},
L:function L(a,b){var _=this
_.a=0
_.b=a
_.c=null
_.$ti=b},
iT:function iT(a,b){this.a=a
this.b=b},
j_:function j_(a,b){this.a=a
this.b=b},
iW:function iW(a){this.a=a},
iX:function iX(a){this.a=a},
iY:function iY(a,b,c){this.a=a
this.b=b
this.c=c},
iV:function iV(a,b){this.a=a
this.b=b},
iZ:function iZ(a,b){this.a=a
this.b=b},
iU:function iU(a,b,c){this.a=a
this.b=b
this.c=c},
j2:function j2(a,b,c){this.a=a
this.b=b
this.c=c},
j3:function j3(a){this.a=a},
j1:function j1(a,b){this.a=a
this.b=b},
j0:function j0(a,b){this.a=a
this.b=b},
fk:function fk(a){this.a=a
this.b=null},
cb:function cb(){},
hY:function hY(a,b){this.a=a
this.b=b},
hZ:function hZ(a,b){this.a=a
this.b=b},
f_:function f_(){},
f0:function f0(){},
fu:function fu(a){this.$ti=a},
dH:function dH(){},
ju:function ju(a,b){this.a=a
this.b=b},
fs:function fs(){},
jd:function jd(a,b){this.a=a
this.b=b},
je:function je(a,b,c){this.a=a
this.b=b
this.c=c},
le(a,b,c,d){var s
if(b==null){if(a==null)return new A.ap(c.l("@<0>").G(d).l("ap<1,2>"))
s=A.mm()}else{if(a==null)a=A.pW()
s=A.mm()}return A.oX(s,a,b,c,d)},
cR(a,b,c){return b.l("@<0>").G(c).l("k0<1,2>").a(A.mq(a,new A.ap(b.l("@<0>").G(c).l("ap<1,2>"))))},
J(a,b){return new A.ap(a.l("@<0>").G(b).l("ap<1,2>"))},
oX(a,b,c,d,e){var s=c!=null?c:new A.jc(d)
return new A.dp(a,b,s,d.l("@<0>").G(e).l("dp<1,2>"))},
nH(a){return new A.dq(a.l("dq<0>"))},
kl(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s},
oY(a,b,c){var s=new A.bN(a,b,c.l("bN<0>"))
s.c=a.e
return s},
pm(a,b){return J.au(a,b)},
pn(a){return J.dQ(a)},
nB(a,b,c){var s,r
if(A.kw(a)){if(b==="("&&c===")")return"(...)"
return b+"..."+c}s=A.b([],t.s)
B.b.A($.am,a)
try{A.pD(a,s)}finally{if(0>=$.am.length)return A.a($.am,-1)
$.am.pop()}r=A.lD(b,t.R.a(s),", ")+c
return r.charCodeAt(0)==0?r:r},
jX(a,b,c){var s,r
if(A.kw(a))return b+"..."+c
s=new A.bh(b)
B.b.A($.am,a)
try{r=s
r.a=A.lD(r.a,a,", ")}finally{if(0>=$.am.length)return A.a($.am,-1)
$.am.pop()}s.a+=c
r=s.a
return r.charCodeAt(0)==0?r:r},
kw(a){var s,r
for(s=$.am.length,r=0;r<s;++r)if(a===$.am[r])return!0
return!1},
pD(a,b){var s,r,q,p,o,n,m,l=a.gZ(a),k=0,j=0
while(!0){if(!(k<80||j<3))break
if(!l.C())return
s=A.v(l.gH())
B.b.A(b,s)
k+=s.length+2;++j}if(!l.C()){if(j<=5)return
if(0>=b.length)return A.a(b,-1)
r=b.pop()
if(0>=b.length)return A.a(b,-1)
q=b.pop()}else{p=l.gH();++j
if(!l.C()){if(j<=4){B.b.A(b,A.v(p))
return}r=A.v(p)
if(0>=b.length)return A.a(b,-1)
q=b.pop()
k+=r.length+2}else{o=l.gH();++j
for(;l.C();p=o,o=n){n=l.gH();++j
if(j>100){while(!0){if(!(k>75&&j>3))break
if(0>=b.length)return A.a(b,-1)
k-=b.pop().length+2;--j}B.b.A(b,"...")
return}}q=A.v(p)
r=A.v(o)
k+=r.length+q.length+4}}if(j>b.length+2){k+=5
m="..."}else m=null
while(!0){if(!(k>80&&b.length>3))break
if(0>=b.length)return A.a(b,-1)
k-=b.pop().length+2
if(m==null){k+=5
m="..."}}if(m!=null)B.b.A(b,m)
B.b.A(b,q)
B.b.A(b,r)},
lf(a,b,c){var s=A.le(null,null,b,c)
a.av(0,new A.hz(s,b,c))
return s},
k2(a){var s,r={}
if(A.kw(a))return"{...}"
s=new A.bh("")
try{B.b.A($.am,a)
s.a+="{"
r.a=!0
a.av(0,new A.hC(r,s))
s.a+="}"}finally{if(0>=$.am.length)return A.a($.am,-1)
$.am.pop()}r=s.a
return r.charCodeAt(0)==0?r:r},
dp:function dp(a,b,c,d){var _=this
_.w=a
_.x=b
_.y=c
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=d},
jc:function jc(a){this.a=a},
dq:function dq(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
fr:function fr(a){this.a=a
this.b=null},
bN:function bN(a,b,c){var _=this
_.a=a
_.b=b
_.d=_.c=null
_.$ti=c},
cM:function cM(){},
hz:function hz(a,b,c){this.a=a
this.b=b
this.c=c},
cS:function cS(){},
q:function q(){},
cT:function cT(){},
hC:function hC(a,b){this.a=a
this.b=b},
Y:function Y(){},
ds:function ds(a,b){this.a=a
this.$ti=b},
dt:function dt(a,b,c){var _=this
_.a=a
_.b=b
_.c=null
_.$ti=c},
d4:function d4(){},
dz:function dz(){},
dr:function dr(){},
dI:function dI(){},
o1(a,b,c,d){var s,r
if(b instanceof Uint8Array){s=b
d=s.length
if(d-c<15)return null
r=A.o2(a,s,c,d)
if(r!=null&&a)if(r.indexOf("\ufffd")>=0)return null
return r}return null},
o2(a,b,c,d){var s=a?$.mP():$.mO()
if(s==null)return null
if(0===c&&d===b.length)return A.lJ(s,b)
return A.lJ(s,b.subarray(c,A.ab(c,d,b.length)))},
lJ(a,b){var s,r
try{s=a.decode(b)
return s}catch(r){}return null},
oT(a,b,c,d,e,f,g,h){var s,r,q,p,o,n,m,l,k=h>>>2,j=3-(h&3)
for(s=b.length,r=f.length,q=c,p=0;q<d;++q){if(!(q<s))return A.a(b,q)
o=b[q]
p=(p|o)>>>0
k=(k<<8|o)&16777215;--j
if(j===0){n=g+1
m=B.d.W(a,k>>>18&63)
if(!(g<r))return A.a(f,g)
f[g]=m
g=n+1
m=B.d.W(a,k>>>12&63)
if(!(n<r))return A.a(f,n)
f[n]=m
n=g+1
m=B.d.W(a,k>>>6&63)
if(!(g<r))return A.a(f,g)
f[g]=m
g=n+1
m=B.d.W(a,k&63)
if(!(n<r))return A.a(f,n)
f[n]=m
k=0
j=3}}if(p>=0&&p<=255){if(e&&j<3){n=g+1
l=n+1
if(3-j===1){s=B.d.W(a,k>>>2&63)
if(!(g<r))return A.a(f,g)
f[g]=s
s=B.d.W(a,k<<4&63)
if(!(n<r))return A.a(f,n)
f[n]=s
g=l+1
if(!(l<r))return A.a(f,l)
f[l]=61
if(!(g<r))return A.a(f,g)
f[g]=61}else{s=B.d.W(a,k>>>10&63)
if(!(g<r))return A.a(f,g)
f[g]=s
s=B.d.W(a,k>>>4&63)
if(!(n<r))return A.a(f,n)
f[n]=s
g=l+1
s=B.d.W(a,k<<2&63)
if(!(l<r))return A.a(f,l)
f[l]=s
if(!(g<r))return A.a(f,g)
f[g]=61}return 0}return(k<<2|3-j)>>>0}for(q=c;q<d;){if(!(q<s))return A.a(b,q)
o=b[q]
if(o<0||o>255)break;++q}if(!(q<s))return A.a(b,q)
throw A.d(A.bS(b,"Not a byte value at index "+q+": 0x"+J.n3(b[q],16),null))},
ld(a,b,c){return new A.cP(a,b)},
po(a){return a.eZ()},
oW(a,b){return new A.fq(a,[],A.mn())},
lW(a,b,c){var s,r,q=new A.bh("")
if(c==null)s=A.oW(q,b)
else s=new A.j9(c,0,q,[],A.mn())
s.bc(a)
r=q.a
return r.charCodeAt(0)==0?r:r},
m2(a){switch(a){case 65:return"Missing extension byte"
case 67:return"Unexpected extension byte"
case 69:return"Invalid UTF-8 byte"
case 71:return"Overlong encoding"
case 73:return"Out of unicode range"
case 75:return"Encoded surrogate"
case 77:return"Unfinished UTF-8 octet sequence"
default:return""}},
pf(a,b,c){var s,r,q,p,o=c-b,n=new Uint8Array(o)
for(s=a.length,r=0;r<o;++r){q=b+r
if(!(q<s))return A.a(a,q)
p=a[q]
if((p&4294967040)>>>0!==0)p=255
if(!(r<o))return A.a(n,r)
n[r]=p}return n},
ib:function ib(){},
ia:function ia(){},
fy:function fy(){},
fx:function fx(){},
dR:function dR(){},
iL:function iL(a){this.a=0
this.b=a},
fl:function fl(){},
fB:function fB(a,b){this.a=a
this.b=b},
b7:function b7(){},
dT:function dT(){},
aL:function aL(){},
av:function av(){},
aw:function aw(){},
e1:function e1(){},
cP:function cP(a,b){this.a=a
this.b=b},
ey:function ey(a,b){this.a=a
this.b=b},
ex:function ex(){},
ez:function ez(a,b){this.a=a
this.b=b},
ja:function ja(){},
jb:function jb(a,b){this.a=a
this.b=b},
j7:function j7(){},
j8:function j8(a,b){this.a=a
this.b=b},
fq:function fq(a,b,c){this.c=a
this.a=b
this.b=c},
j9:function j9(a,b,c,d,e){var _=this
_.f=a
_.a$=b
_.c=c
_.a=d
_.b=e},
eA:function eA(){},
eC:function eC(){},
eB:function eB(a){this.a=a},
f1:function f1(){},
f2:function f2(){},
dB:function dB(a,b){this.a=a
this.$ti=b},
fD:function fD(a,b,c){this.a=a
this.b=b
this.c=c},
fb:function fb(){},
fd:function fd(){},
jm:function jm(a){this.b=0
this.c=a},
fc:function fc(a){this.a=a},
fC:function fC(a){this.a=a
this.b=16
this.c=0},
fE:function fE(){},
nh(a){if(a instanceof A.b9)return a.u(0)
return"Instance of '"+A.hP(a)+"'"},
ni(a,b){a=A.d(a)
if(a==null)a=t.K.a(a)
a.stack=b.u(0)
throw a
throw A.d("unreachable")},
H(a,b,c,d){var s,r=c?J.eq(a,d):J.jY(a,d)
if(a!==0&&b!=null)for(s=0;s<r.length;++s)r[s]=b
return r},
lg(a,b){var s,r=A.b([],b.l("p<0>"))
for(s=J.aK(a);s.C();)B.b.A(r,b.a(s.gH()))
return r},
hA(a,b,c){var s=A.nI(a,c)
return s},
nI(a,b){var s,r
if(Array.isArray(a))return A.b(a.slice(0),b.l("p<0>"))
s=A.b([],b.l("p<0>"))
for(r=J.aK(a);r.C();)B.b.A(s,r.gH())
return s},
k1(a,b,c,d){var s,r=c?J.eq(a,d):J.jY(a,d)
for(s=0;s<a;++s)B.b.h(r,s,b.$1(s))
return r},
i_(a,b,c){var s,r
if(Array.isArray(a)){s=a
r=s.length
c=A.ab(b,c,r)
return A.lt(b>0||c<r?s.slice(b,c):s)}if(t.hD.b(a))return A.nR(a,b,A.ab(b,c,a.length))
return A.nX(a,b,c)},
nX(a,b,c){var s,r,q,p,o=null
if(b<0)throw A.d(A.Q(b,0,a.length,o,o))
s=c==null
if(!s&&c<b)throw A.d(A.Q(c,b,a.length,o,o))
r=J.aK(a)
for(q=0;q<b;++q)if(!r.C())throw A.d(A.Q(b,0,q,o,o))
p=[]
if(s)for(;r.C();)p.push(r.gH())
else for(q=b;q<c;++q){if(!r.C())throw A.d(A.Q(c,b,q,o,o))
p.push(r.gH())}return A.lt(p)},
nU(a){return new A.et(a,A.nF(a,!1,!0,!1,!1,!1))},
lD(a,b,c){var s=J.aK(b)
if(!s.C())return a
if(c.length===0){do a+=A.v(s.gH())
while(s.C())}else{a+=A.v(s.gH())
for(;s.C();)a=a+c+A.v(s.gH())}return a},
jl(a,b,c,d){var s,r,q,p,o,n,m="0123456789ABCDEF"
if(c===B.t){s=$.mU().b
s=s.test(b)}else s=!1
if(s)return b
A.w(c).l("av.S").a(b)
r=c.gd5().aY(b)
for(s=r.length,q=0,p="";q<s;++q){o=r[q]
if(o<128){n=o>>>4
if(!(n<8))return A.a(a,n)
n=(a[n]&1<<(o&15))!==0}else n=!1
if(n)p+=A.B(o)
else p=p+"%"+m[o>>>4&15]+m[o&15]}return p.charCodeAt(0)==0?p:p},
lC(){var s,r
if(A.b0($.mY()))return A.an(new Error())
try{throw A.d("")}catch(r){s=A.an(r)
return s}},
nf(a,b){var s
if(Math.abs(a)<=864e13)s=!1
else s=!0
if(s)A.F(A.bu("DateTime is outside valid range: "+a,null))
A.cl(!0,"isUtc",t.v)
return new A.bx(a,!0)},
kU(a){var s=Math.abs(a),r=a<0?"-":""
if(s>=1000)return""+a
if(s>=100)return r+"0"+s
if(s>=10)return r+"00"+s
return r+"000"+s},
ng(a){var s=Math.abs(a),r=a<0?"-":"+"
if(s>=1e5)return r+s
return r+"0"+s},
kV(a){if(a>=100)return""+a
if(a>=10)return"0"+a
return"00"+a},
aM(a){if(a>=10)return""+a
return"0"+a},
cv(a){if(typeof a=="number"||A.dJ(a)||a==null)return J.bR(a)
if(typeof a=="string")return JSON.stringify(a)
return A.nh(a)},
fK(a){return new A.cq(a)},
bu(a,b){return new A.aF(!1,null,b,a)},
bS(a,b,c){return new A.aF(!0,a,b,c)},
Q(a,b,c,d,e){return new A.d3(b,c,!0,a,d,"Invalid value")},
ab(a,b,c){if(0>a||a>c)throw A.d(A.Q(a,0,c,"start",null))
if(b!=null){if(a>b||b>c)throw A.d(A.Q(b,a,c,"end",null))
return b}return c},
eX(a,b){if(a<0)throw A.d(A.Q(a,0,null,b,null))
return a},
hn(a,b,c,d,e){var s=A.o(e==null?J.b5(b):e)
return new A.ec(s,!0,a,c,"Index out of range")},
Z(a){return new A.fa(a)},
da(a){return new A.f8(a)},
hX(a){return new A.ca(a)},
ba(a){return new A.dY(a)},
kX(a){return new A.iS(a)},
h4(a,b,c){return new A.e6(a,b,c)},
l7(a,b,c){if(a<=0)return new A.bz(c.l("bz<0>"))
return new A.dn(a,b,c.l("dn<0>"))},
jM(a){A.mw(A.v(a))},
o0(a,b,c,d,e){var s,r=10===a.length&&A.pl("text/plain",a,0)>=0
if(r)a=""
if(a.length===0||a==="application/octet-stream")d.a+=a
else{s=A.o_(a)
if(s<0)throw A.d(A.bS(a,"mimeType","Invalid MIME type"))
r=d.a+=A.jl(B.L,B.d.aT(a,0,s),B.t,!1)
d.a=r+"/"
d.a+=A.jl(B.L,B.d.dk(a,s+1),B.t,!1)}c.av(0,new A.i9(e,d))},
o_(a){var s,r,q
for(s=a.length,r=-1,q=0;q<s;++q){if(B.d.W(a,q)!==47)continue
if(r<0){r=q
continue}return-1}return r},
pl(a,b,c){var s,r,q,p,o,n,m
for(s=a.length,r=0,q=0;q<s;++q){p=B.d.W(a,q)
o=B.d.W(b,c+q)
n=p^o
if(n!==0){if(n===32){m=o|n
if(97<=m&&m<=122){r=32
continue}}return-1}}return r},
bx:function bx(a,b){this.a=a
this.b=b},
iO:function iO(){},
x:function x(){},
cq:function cq(a){this.a=a},
bi:function bi(){},
eJ:function eJ(){},
aF:function aF(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
d3:function d3(a,b,c,d,e,f){var _=this
_.e=a
_.f=b
_.a=c
_.b=d
_.c=e
_.d=f},
ec:function ec(a,b,c,d,e){var _=this
_.f=a
_.a=b
_.b=c
_.c=d
_.d=e},
fa:function fa(a){this.a=a},
f8:function f8(a){this.a=a},
ca:function ca(a){this.a=a},
dY:function dY(a){this.a=a},
eK:function eK(){},
d6:function d6(){},
dZ:function dZ(a){this.a=a},
iS:function iS(a){this.a=a},
e6:function e6(a,b,c){this.a=a
this.b=b
this.c=c},
k:function k(){},
dn:function dn(a,b,c){this.a=a
this.b=b
this.$ti=c},
I:function I(){},
K:function K(){},
t:function t(){},
fv:function fv(){},
bh:function bh(a){this.a=a},
i8:function i8(a,b){this.a=a
this.b=b},
i9:function i9(a,b){this.a=a
this.b=b},
iQ(a,b,c,d,e){var s=A.pP(new A.iR(c),t.V)
if(s!=null&&!0)J.n_(a,b,s,!1)
return new A.dm(a,b,s,!1,e.l("dm<0>"))},
pP(a,b){var s=$.C
if(s===B.h)return a
return s.js(a,b)},
bw:function bw(){},
bY:function bY(){},
h_:function h_(){},
i:function i(){},
aN:function aN(){},
c_:function c_(){},
aT:function aT(){},
bc:function bc(){},
bm:function bm(){},
jR:function jR(a){this.$ti=a},
iP:function iP(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.$ti=d},
dm:function dm(a,b,c,d,e){var _=this
_.b=a
_.c=b
_.d=c
_.e=d
_.$ti=e},
iR:function iR(a){this.a=a},
jf:function jf(){},
jg:function jg(a,b){this.a=a
this.b=b},
jh:function jh(a,b){this.a=a
this.b=b},
iF:function iF(){},
iG:function iG(a,b){this.a=a
this.b=b},
fw:function fw(a,b){this.a=a
this.b=b},
fh:function fh(a,b){this.a=a
this.b=b
this.c=!1},
qh(a,b){var s=new A.L($.C,b.l("L<0>")),r=new A.bM(s,b.l("bM<0>"))
a.then(A.bQ(new A.jN(r,b),1),A.bQ(new A.jO(r),1))
return s},
jN:function jN(a,b){this.a=a
this.b=b},
jO:function jO(a){this.a=a},
hG:function hG(a){this.a=a},
cp(a){return new A.fJ(a,null,null)},
fJ:function fJ(a,b,c){this.a=a
this.b=b
this.c=c},
bB(a,b,c,d){var s,r
if(t.bl.b(a))s=A.z(a.buffer,a.byteOffset,a.byteLength)
else s=t.L.b(a)?a:A.lg(t.R.a(a),t.p)
r=new A.ee(s,d,d,b)
r.e=c==null?s.length:c
return r},
ef:function ef(){},
ee:function ee(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=$},
hJ(a,b){var s=b==null?32768:b
return new A.hI(a,new Uint8Array(s))},
hK:function hK(){},
hI:function hI(a,b){this.a=0
this.b=a
this.c=b},
jo:function jo(){},
kW(a,b,c,d){var s,r=b*2,q=a.length
if(!(r>=0&&r<q))return A.a(a,r)
r=a[r]
s=c*2
if(!(s>=0&&s<q))return A.a(a,s)
s=a[s]
if(r>=s)if(r===s){if(!(b>=0&&b<573))return A.a(d,b)
r=d[b]
if(!(c>=0&&c<573))return A.a(d,c)
r=r<=d[c]}else r=!1
else r=!0
return r},
kk(){return new A.j4()},
oU(a,b,c){var s,r,q,p,o,n,m,l=new Uint16Array(16)
for(s=0,r=1;r<=15;++r){s=s+c[r-1]<<1>>>0
if(!(r<16))return A.a(l,r)
l[r]=s}for(q=a.length,p=0;p<=b;++p){o=p*2
n=o+1
if(!(n<q))return A.a(a,n)
m=a[n]
if(m===0)continue
if(!(m>=0&&m<16))return A.a(l,m)
n=l[m]
if(!(m<16))return A.a(l,m)
l[m]=n+1
n=A.oV(n,m)
if(!(o<q))return A.a(a,o)
a[o]=n}},
oV(a,b){var s,r=0
do{s=A.ad(a,1)
r=(r|a&1)<<1>>>0
if(--b,b>0){a=s
continue}else break}while(!0)
return A.ad(r,1)},
lT(a){var s
if(a<256){if(!(a>=0))return A.a(B.D,a)
s=B.D[a]}else{s=256+A.ad(a,7)
if(!(s<512))return A.a(B.D,s)
s=B.D[s]}return s},
kn(a,b,c,d,e){return new A.ft(a,b,c,d,e)},
ad(a,b){if(a>=0)return B.a.a8(a,b)
else return B.a.a8(a,b)+B.a.B(2,(~b>>>0)+65536&65535)},
fY:function fY(a,b,c,d,e,f,g,h){var _=this
_.b=_.a=0
_.c=a
_.d=b
_.e=null
_.x=_.w=_.r=_.f=$
_.y=2
_.k1=_.id=_.go=_.fy=_.fx=_.fr=_.dy=_.dx=_.db=_.cy=_.cx=_.CW=_.ch=_.ay=_.ax=_.at=_.as=$
_.k2=0
_.p4=_.p3=_.p2=_.p1=_.ok=_.k4=_.k3=$
_.R8=c
_.RG=d
_.rx=e
_.ry=f
_.to=g
_.x2=_.x1=$
_.xr=h
_.aj=_.ae=_.aM=_.aZ=_.aL=_.ab=_.au=_.ai=_.y2=_.y1=$},
as:function as(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
j4:function j4(){this.c=this.b=this.a=$},
ft:function ft(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
c1(a){var s=new A.ha()
s.fA(a)
return s},
ha:function ha(){this.a=$
this.b=0
this.c=2147483647},
l4(a){var s=A.c1(B.a8),r=A.c1(B.ar)
r=new A.ed(A.bB(a,0,null,0),A.hJ(0,null),s,r)
r.b=!0
r.dY()
return r},
ed:function ed(a,b,c,d){var _=this
_.a=a
_.b=!1
_.c=b
_.e=_.d=0
_.r=c
_.w=d},
iD:function iD(){},
iC:function iC(){},
iE:function iE(){},
qf(){return A.pV(new A.jJ(),null)},
jJ:function jJ(){},
c4:function c4(){this.a=$},
hh:function hh(a){this.a=a},
hi:function hi(a){this.a=a},
hj:function hj(a){this.a=a},
hk:function hk(a){this.a=a},
kY(a){var s=t.p,r=t.z
s=new A.bZ(a==null?A.J(s,r):A.lf(a.b,s,r))
s.fs(a)
return s},
bZ:function bZ(a){this.a=null
this.b=a},
kO(a){var s,r,q=new A.fQ()
if(!A.fR(a))A.F(A.f("Not a bitmap file."))
a.d+=2
s=a.j()
r=$.A()
r[0]=s
s=$.P()
if(0>=s.length)return A.a(s,0)
q.a=s[0]
a.d+=4
r[0]=a.j()
if(0>=s.length)return A.a(s,0)
q.b=s[0]
return q},
fR(a){if(a.c-a.d<2)return!1
return A.j(a,null,0).k()===19778},
n5(a,b){var s,r,q,p,o,n,m,l=b==null?A.kO(a):b,k=a.j(),j=a.j(),i=$.A()
i[0]=j
j=$.P()
if(0>=j.length)return A.a(j,0)
s=j[0]
i[0]=a.j()
if(0>=j.length)return A.a(j,0)
r=j[0]
q=a.k()
p=a.k()
o=a.j()
n=A.cR([0,B.O,3,B.N],t.p,t.G).q(0,o)
if(n==null)A.F(A.f("Bitmap compression "+o+" is not supported yet."))
o=a.j()
i[0]=a.j()
if(0>=j.length)return A.a(j,0)
m=j[0]
i[0]=a.j()
if(0>=j.length)return A.a(j,0)
j=new A.b6(l,r,s,k,q,p,n,o,m,j[0],a.j(),a.j())
j.dm(a,b)
return j},
cs:function cs(a,b){this.a=a
this.b=b},
fQ:function fQ(){this.b=this.a=$},
b6:function b6(a,b,c,d,e,f,g,h,i,j,k,l){var _=this
_.d=a
_.e=b
_.f=c
_.r=d
_.w=e
_.x=f
_.y=g
_.z=h
_.Q=i
_.as=j
_.at=k
_.ax=l
_.cy=_.cx=_.CW=_.ch=_.ay=null
_.b=_.a=0},
fV:function fV(a,b,c){this.a=a
this.b=b
this.c=c},
bT:function bT(){this.a=$
this.b=null},
fT:function fT(a,b,c){this.a=a
this.b=b
this.c=c},
e_:function e_(){this.a=$
this.b=null},
fU:function fU(){},
fX:function fX(){},
a9:function a9(){},
h0:function h0(){},
e2:function e2(){},
cH:function cH(a,b){var _=this
_.r=a
_.b=_.a=0
_.c=b},
e3:function e3(){var _=this
_.a=null
_.f=_.e=_.c=_.b=$},
kZ(a,b,c,d){var s,r
switch(a){case 1:return new A.ek(b)
case 2:return new A.cJ(d==null?1:d,b)
case 3:return new A.cJ(d==null?16:d,b)
case 4:s=d==null?32:d
r=new A.ei(c,s,b)
r.fB(b,c,s)
return r
case 5:return new A.ej(c,d==null?16:d,b)
case 6:return new A.cH(d==null?32:d,b)
case 7:return new A.cH(d==null?32:d,b)
default:throw A.d(A.f("Invalid compression type: "+a))}},
aO:function aO(){},
eh:function eh(){},
nm(a,b,c,d){var s,r,q,p,o,n,m,l
if(b===0){if(d!==0)throw A.d(A.f("Incomplete huffman data"))
return}s=a.d
r=a.j()
q=a.j()
a.d+=4
p=a.j()
if(r<65537)o=q>=65537
else o=!0
if(o)throw A.d(A.f("Invalid huffman table size"))
a.d+=4
n=A.H(65537,0,!1,t.p)
m=J.ah(16384,t.ho)
for(l=0;l<16384;++l)m[l]=new A.e4()
A.nn(a,b-20,r,q,n)
if(p>8*(b-(a.d-s)))throw A.d(A.f("Error in header for Huffman-encoded data (invalid number of bits)."))
A.nj(n,r,q,m)
A.nl(n,m,a,p,q,d,c)},
nl(a,b,c,d,e,f,g){var s,r,q,p,o,n,m,l,k,j="Error in Huffman-encoded data (invalid code).",i=A.b([0,0],t.t),h=c.d+B.a.F(d+7,8)
for(s=b.length,r=0;c.d<h;){A.jS(i,c)
for(;q=i[1],q>=14;){p=B.a.a8(i[0],q-14)&16383
if(!(p<s))return A.a(b,p)
o=b[p]
p=o.a
if(p!==0){B.b.h(i,1,q-p)
r=A.jT(o.b,e,i,c,g,r,f)}else{if(o.c==null)throw A.d(A.f(j))
for(n=0;n<o.b;++n){q=o.c
if(!(n<q.length))return A.a(q,n)
q=q[n]
if(!(q<65537))return A.a(a,q)
m=a[q]&63
while(!0){q=i[1]
if(!(q<m&&c.d<h))break
A.jS(i,c)}if(q>=m){p=o.c
if(!(n<p.length))return A.a(p,n)
p=p[n]
if(!(p<65537))return A.a(a,p)
q-=m
if(a[p]>>>6===(B.a.a8(i[0],q)&B.a.B(1,m)-1)>>>0){B.b.h(i,1,q)
q=o.c
if(!(n<q.length))return A.a(q,n)
l=A.jT(q[n],e,i,c,g,r,f)
r=l
break}}}if(n===o.b)throw A.d(A.f(j))}}}k=8-d&7
B.b.h(i,0,B.a.i(i[0],k))
B.b.h(i,1,i[1]-k)
for(;q=i[1],q>0;){p=B.a.D(i[0],14-q)&16383
if(!(p<s))return A.a(b,p)
o=b[p]
p=o.a
if(p!==0){B.b.h(i,1,q-p)
r=A.jT(o.b,e,i,c,g,r,f)}else throw A.d(A.f(j))}if(r!==f)throw A.d(A.f("Error in Huffman-encoded data (decoded data are shorter than expected)."))},
jT(a,b,c,d,e,f,g){var s,r,q,p,o,n,m="Error in Huffman-encoded data (decoded data are longer than expected)."
if(a===b){if(c[1]<8)A.jS(c,d)
B.b.h(c,1,c[1]-8)
s=B.a.a8(c[0],c[1])&255
if(f+s>g)throw A.d(A.f(m))
r=f-1
q=e.length
if(!(r>=0&&r<q))return A.a(e,r)
p=e[r]
for(;o=s-1,s>0;s=o,f=n){n=f+1
if(!(f<q))return A.a(e,f)
e[f]=p}}else{if(f<g){n=f+1
if(!(f<e.length))return A.a(e,f)
e[f]=a}else throw A.d(A.f(m))
f=n}return f},
nj(a,b,c,d){var s,r,q,p,o,n,m,l,k,j,i="Error in Huffman-encoded data (invalid code table entry)."
for(s=d.length,r=t.t,q=t.p;b<=c;++b){if(!(b<65537))return A.a(a,b)
p=a[b]
o=p>>>6
n=p&63
if(B.a.L(o,n)!==0)throw A.d(A.f(i))
if(n>14){p=B.a.a5(o,n-14)
if(!(p<s))return A.a(d,p)
m=d[p]
if(m.a!==0)throw A.d(A.f(i))
p=++m.b
l=m.c
if(l!=null){m.seP(A.H(p,0,!1,q))
for(k=0;k<m.b-1;++k){p=m.c
p.toString
if(!(k<l.length))return A.a(l,k)
B.b.h(p,k,l[k])}}else m.seP(A.b([0],r))
p=m.c
p.toString
B.b.h(p,m.b-1,b)}else if(n!==0){p=14-n
j=B.a.D(o,p)
if(!(j<s))return A.a(d,j)
for(k=B.a.D(1,p);k>0;--k,++j){if(!(j<s))return A.a(d,j)
m=d[j]
if(m.a!==0||m.c!=null)throw A.d(A.f(i))
m.a=n
m.b=b}}}},
nn(a,b,c,d,e){var s,r,q,p,o,n="Error in Huffman-encoded data (unexpected end of code table data).",m="Error in Huffman-encoded data (code table is longer than expected).",l=a.d,k=A.b([0,0],t.t)
for(s=d+1;c<=d;++c){if(a.d-l>b)throw A.d(A.f(n))
r=A.l_(6,k,a)
B.b.h(e,c,r)
if(r===63){if(a.d-l>b)throw A.d(A.f(n))
q=A.l_(8,k,a)+6
if(c+q>s)throw A.d(A.f(m))
for(;p=q-1,q!==0;q=p,c=o){o=c+1
B.b.h(e,c,0)}--c}else if(r>=59){q=r-59+2
if(c+q>s)throw A.d(A.f(m))
for(;p=q-1,q!==0;q=p,c=o){o=c+1
B.b.h(e,c,0)}--c}}A.nk(e)},
nk(a){var s,r,q,p,o,n=A.H(59,0,!1,t.p)
for(s=0;s<65537;++s){r=a[s]
if(!(r<59))return A.a(n,r)
B.b.h(n,r,n[r]+1)}for(q=0,s=58;s>0;--s,q=p){p=q+n[s]>>>1
B.b.h(n,s,q)}for(s=0;s<65537;++s){o=a[s]
if(o>0){if(!(o<59))return A.a(n,o)
r=n[o]
B.b.h(n,o,r+1)
B.b.h(a,s,(o|r<<6)>>>0)}}},
jS(a,b){B.b.h(a,0,((a[0]<<8|b.t())&-1)>>>0)
B.b.h(a,1,(a[1]+8&-1)>>>0)},
l_(a,b,c){var s,r,q
for(;s=b[1],s<a;){s=b[0]
r=c.a
q=c.d++
if(!(q>=0&&q<r.length))return A.a(r,q)
B.b.h(b,0,((s<<8|r[q])&-1)>>>0)
B.b.h(b,1,(b[1]+8&-1)>>>0)}B.b.h(b,1,s-a)
return(B.a.a8(b[0],b[1])&B.a.B(1,a)-1)>>>0},
e4:function e4(){this.b=this.a=0
this.c=null},
no(a){var s=A.l(a,!1,null,0)
if(s.j()!==20000630)return!1
if(s.t()!==2)return!1
if((s.an()&4294967289)>>>0!==0)return!1
return!0},
h1:function h1(a){var _=this
_.d=a
_.e=null
_.f=$
_.b=_.a=0},
l5(a,b){var s=new A.cI(new A.e9(A.J(t.jv,t.r)),A.b([],t.a_),A.J(t.N,t.iW),a)
s.fv(a,b,{})
return s},
e5:function e5(){},
h2:function h2(a,b){this.a=a
this.b=b},
cI:function cI(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.e=$
_.r=_.f=null
_.Q=$
_.as=0
_.at=null
_.ax=$
_.CW=_.ch=_.ay=null
_.cx=d
_.go=_.fy=_.fx=_.fr=_.dy=_.dx=_.db=_.cy=null
_.id=$
_.k1=null},
ei:function ei(a,b,c){var _=this
_.r=null
_.w=a
_.x=b
_.y=$
_.z=null
_.b=_.a=0
_.c=c},
dy:function dy(){var _=this
_.f=_.e=_.d=_.c=_.b=_.a=$},
ej:function ej(a,b,c){var _=this
_.w=a
_.x=b
_.y=null
_.b=_.a=0
_.c=c},
ek:function ek(a){var _=this
_.r=null
_.b=_.a=0
_.c=a},
cJ:function cJ(a,b){var _=this
_.w=a
_.x=null
_.b=_.a=0
_.c=b},
cz:function cz(){this.a=null},
l0(a){var s=new Uint8Array(a*3)
return new A.e7(A.nv(a),a,null,s)},
nv(a){var s
for(s=1;s<=8;++s)if(B.a.B(1,s)>=a)return s
return 0},
e7:function e7(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
cE:function cE(){},
el:function el(){var _=this
_.e=_.d=_.c=_.b=_.a=$
_.f=null
_.x=$},
e8:function e8(a){var _=this
_.e=null
_.r=a
_.b=_.a=0},
cD:function cD(){var _=this
_.d=_.b=_.a=null
_.f=_.e=$
_.r=null
_.w=0
_.x=null
_.Q=_.z=_.y=0
_.as=null
_.cx=_.CW=_.ch=_.ay=_.ax=_.at=0},
h6:function h6(a){var _=this
_.c=a
_.w=_.r=_.f=null
_.y=_.x=$
_.cx=_.CW=_.ch=_.ay=_.ax=_.at=_.as=_.Q=_.z=0
_.cy=!1
_.db=$
_.dx=0
_.dy=null},
h7:function h7(a,b){this.a=a
this.b=b},
l3(a){var s,r
if(a.k()!==0)return null
s=a.k()
if(!B.b.aB(A.b([1,2],t.t),s))return null
if(s===2)return null
r=a.k()
return new A.he(r,A.l7(r,new A.hf(a),t.aw).aP(0))},
cG:function cG(){this.b=this.a=null},
he:function he(a,b){var _=this
_.e=a
_.f=b
_.b=_.a=0},
hf:function hf(a){this.a=a},
c2:function c2(a,b){this.d=a
this.e=b},
eb:function eb(a,b,c,d,e,f,g,h,i,j,k,l){var _=this
_.d=a
_.e=b
_.f=c
_.r=d
_.w=e
_.x=f
_.y=g
_.z=h
_.Q=i
_.as=j
_.at=k
_.ax=l
_.cy=_.cx=_.CW=_.ch=_.ay=null
_.b=_.a=0},
it:function it(){},
hd:function hd(){},
dX:function dX(a,b,c){this.e=a
this.f=b
this.r=c},
hq:function hq(){this.d=null},
az:function az(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.y=_.x=_.w=_.r=_.f=_.e=$},
lc(){var s=t.lv
return new A.hr(new A.bZ(A.J(t.p,t.z)),A.H(4,null,!1,t.jH),A.b([],t.gU),A.b([],s),A.b([],s),A.b([],t.an))},
hr:function hr(a,b,c,d,e,f){var _=this
_.b=_.a=$
_.e=_.d=_.c=null
_.r=a
_.w=b
_.x=c
_.y=d
_.z=e
_.Q=f},
hs:function hs(a,b){this.a=a
this.b=b},
ch:function ch(a){this.a=a
this.b=0},
eu:function eu(a,b){var _=this
_.e=_.d=_.c=_.b=null
_.r=_.f=0
_.x=_.w=$
_.y=a
_.z=b},
hu:function hu(){this.r=this.f=$},
ev:function ev(a,b,c,d,e,f,g,h){var _=this
_.a=a
_.b=b
_.f=$
_.r=null
_.y=c
_.z=d
_.Q=e
_.as=f
_.at=g
_.ax=h
_.cx=_.CW=_.ch=_.ay=0
_.cy=$},
c7:function c7(){},
ht:function ht(a,b,c,d,e,f,g,h,i,j,k,l){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.f=_.e=null
_.w=_.r=$
_.x=e
_.y=f
_.z=g
_.Q=h
_.as=i
_.at=j
_.ax=k
_.ay=l
_.ch=null
_.CW=0
_.cx=7},
cZ:function cZ(){},
em:function em(a){this.c=this.b=null
this.y=a},
hO:function hO(){},
en:function en(a,b,c){var _=this
_.Q=_.z=_.y=_.x=_.w=_.r=_.e=_.d=null
_.at=""
_.ay=null
_.ch=a
_.cy=b
_.db=c
_.b=_.a=0},
c8:function c8(){var _=this
_.a=null
_.c=_.b=0
_.d=$
_.e=0},
hM:function hM(){},
lk(a){return new A.hN(a)},
hN:function hN(a){var _=this
_.a=null
_.d=a
_.f=_.e=$
_.r=null
_.z=_.y=_.x=_.w=$
_.as=0
_.at=!1
_.ax=null},
eP:function eP(){this.a=null},
eQ:function eQ(){this.a=null},
aG:function aG(){},
eS:function eS(){this.a=null},
eT:function eT(){this.a=null},
eV:function eV(){this.a=null},
eW:function eW(){this.a=null},
d2:function d2(a){this.b=a},
eU:function eU(){},
hQ:function hQ(){var _=this
_.w=_.r=_.f=_.e=$},
bH:function bH(a){this.a=a
this.c=$},
lu(a){var s=new A.hR(A.J(t.p,t.ok))
s.fD(a)
return s},
k7(a,b,c,d){var s=a/255,r=b/255,q=c/255,p=d/255,o=r*(1-q),n=s*(1-p)
return B.c.m(B.c.p((2*s<q?2*r*s+o+n:p*q-2*(q-s)*(p-r)+o+n)*255,0,255))},
hS(a,b){if(b===0)return 0
return B.c.m(B.a.p(B.c.m(255*(1-(1-a/255)/(b/255))),0,255))},
nS(a,b){return B.c.m(B.a.p(a+b-255,0,255))},
hT(a,b){if(b===255)return 255
return B.c.m(B.c.p(a/255/(1-b/255)*255,0,255))},
k8(a,b){var s=a/255,r=b/255,q=1-r
return B.c.aE(255*(q*r*s+r*(1-q*(1-s))))},
k5(a,b){var s=b/255,r=a/255
if(r<0.5)return B.c.aE(510*s*r)
else return B.c.aE(255*(1-2*(1-s)*(1-r)))},
k9(a,b){if(b<128)return A.hS(a,2*b)
else return A.hT(a,2*(b-128))},
k6(a,b){var s
if(b<128)return A.nS(a,2*b)
else{s=2*(b-128)
return s+a>255?255:a+s}},
lv(d1,d2,d3,d4,d5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,c0,c1,c2,c3,c4,c5,c6,c7="data",c8=A.T(d3,d4,B.f,null,null),c9=c8.aw(),d0=A.J(t.p,t.dS)
for(s=d5.length,r=0;q=d5.length,r<q;d5.length===s||(0,A.b3)(d5),++r){p=d5[r]
d0.h(0,p.a,p)}if(d2===8)o=1
else o=d2===16?2:-1
if(o===-1)throw A.d(A.f("PSD: unsupported bit depth: "+A.v(d2)))
n=d0.q(0,0)
m=d0.q(0,1)
l=d0.q(0,2)
k=d0.q(0,-1)
for(s=c9.length,j=q>=5,i=o===1,h=q===4,g=q>=2,q=q>=4,f=0,e=0,d=0;f<d4;++f)for(c=0;c<d3;++c,d+=o)switch(d1){case 3:b=e+1
a=n.c
a===$&&A.c(c7)
a0=a.length
if(i){if(!(d>=0&&d<a0))return A.a(a,d)
a=a[d]}else{if(!(d>=0&&d<a0))return A.a(a,d)
a1=a[d]
a2=d+1
if(!(a2<a0))return A.a(a,a2)
a2=(a1<<8|a[a2])>>>8
a=a2}if(!(e>=0&&e<s))return A.a(c9,e)
c9[e]=a
a3=b+1
a=m.c
a===$&&A.c(c7)
a0=a.length
if(i){if(!(d>=0&&d<a0))return A.a(a,d)
a=a[d]}else{if(!(d>=0&&d<a0))return A.a(a,d)
a1=a[d]
a2=d+1
if(!(a2<a0))return A.a(a,a2)
a2=(a1<<8|a[a2])>>>8
a=a2}if(!(b>=0&&b<s))return A.a(c9,b)
c9[b]=a
a4=a3+1
a=l.c
a===$&&A.c(c7)
a0=a.length
if(i){if(!(d>=0&&d<a0))return A.a(a,d)
a=a[d]}else{if(!(d>=0&&d<a0))return A.a(a,d)
a1=a[d]
a2=d+1
if(!(a2<a0))return A.a(a,a2)
a2=(a1<<8|a[a2])>>>8
a=a2}if(!(a3>=0&&a3<s))return A.a(c9,a3)
c9[a3]=a
a3=a4+1
if(q){a=k.c
a===$&&A.c(c7)
a0=a.length
if(i){if(!(d>=0&&d<a0))return A.a(a,d)
a=a[d]}else{if(!(d>=0&&d<a0))return A.a(a,d)
a1=a[d]
a2=d+1
if(!(a2<a0))return A.a(a,a2)
a2=(a1<<8|a[a2])>>>8
a=a2}}else a=255
if(!(a4>=0&&a4<s))return A.a(c9,a4)
c9[a4]=a
a5=c9[e]
a6=c9[b]
a=e+2
if(!(a<s))return A.a(c9,a)
a7=c9[a]
a0=e+3
if(!(a0<s))return A.a(c9,a0)
a8=c9[a0]
if(a8!==0){c9[e]=B.a.V((a5+a8-255)*255,a8)
c9[b]=B.a.V((a6+a8-255)*255,a8)
c9[a]=B.a.V((a7+a8-255)*255,a8)}e=a3
break
case 9:a=n.c
a===$&&A.c(c7)
a0=a.length
if(i){if(!(d>=0&&d<a0))return A.a(a,d)
a=a[d]}else{if(!(d>=0&&d<a0))return A.a(a,d)
a1=a[d]
a2=d+1
if(!(a2<a0))return A.a(a,a2)
a2=(a1<<8|a[a2])>>>8
a=a2}a0=m.c
a0===$&&A.c(c7)
a1=a0.length
if(i){if(!(d>=0&&d<a1))return A.a(a0,d)
a0=a0[d]}else{if(!(d>=0&&d<a1))return A.a(a0,d)
a2=a0[d]
a9=d+1
if(!(a9<a1))return A.a(a0,a9)
a9=(a2<<8|a0[a9])>>>8
a0=a9}a1=l.c
a1===$&&A.c(c7)
a2=a1.length
if(i){if(!(d>=0&&d<a2))return A.a(a1,d)
a1=a1[d]}else{if(!(d>=0&&d<a2))return A.a(a1,d)
a9=a1[d]
b0=d+1
if(!(b0<a2))return A.a(a1,b0)
b0=(a9<<8|a1[b0])>>>8
a1=b0}if(q){a2=k.c
a2===$&&A.c(c7)
a9=a2.length
if(i){if(!(d>=0&&d<a9))return A.a(a2,d)
a2=a2[d]
b1=a2}else{if(!(d>=0&&d<a9))return A.a(a2,d)
b0=a2[d]
b2=d+1
if(!(b2<a9))return A.a(a2,b2)
b2=(b0<<8|a2[b2])>>>8
b1=b2}}else b1=255
b3=((a*100>>>8)+16)/116
b4=(a0-128)/500+b3
b5=b3-(a1-128)/200
b6=Math.pow(b3,3)
b3=b6>0.008856?b6:(b3-0.13793103448275862)/7.787
b7=Math.pow(b4,3)
b4=b7>0.008856?b7:(b4-0.13793103448275862)/7.787
b8=Math.pow(b5,3)
b5=b8>0.008856?b8:(b5-0.13793103448275862)/7.787
b4=b4*95.047/100
b3=b3*100/100
b5=b5*108.883/100
b9=b4*3.2406+b3*-1.5372+b5*-0.4986
c0=b4*-0.9689+b3*1.8758+b5*0.0415
c1=b4*0.0557+b3*-0.204+b5*1.057
b9=b9>0.0031308?1.055*Math.pow(b9,0.4166666666666667)-0.055:12.92*b9
c0=c0>0.0031308?1.055*Math.pow(c0,0.4166666666666667)-0.055:12.92*c0
c1=c1>0.0031308?1.055*Math.pow(c1,0.4166666666666667)-0.055:12.92*c1
c2=[B.c.m(B.c.p(b9*255,0,255)),B.c.m(B.c.p(c0*255,0,255)),B.c.m(B.c.p(c1*255,0,255))]
b=e+1
a=c2[0]
if(!(e>=0&&e<s))return A.a(c9,e)
c9[e]=a
e=b+1
a=c2[1]
if(!(b>=0&&b<s))return A.a(c9,b)
c9[b]=a
b=e+1
a=c2[2]
if(!(e>=0&&e<s))return A.a(c9,e)
c9[e]=a
e=b+1
if(!(b>=0&&b<s))return A.a(c9,b)
c9[b]=b1
break
case 1:a=n.c
a===$&&A.c(c7)
a0=a.length
if(i){if(!(d>=0&&d<a0))return A.a(a,d)
c3=a[d]}else{if(!(d>=0&&d<a0))return A.a(a,d)
a1=a[d]
a2=d+1
if(!(a2<a0))return A.a(a,a2)
c3=(a1<<8|a[a2])>>>8}if(g){a=k.c
a===$&&A.c(c7)
a0=a.length
if(i){if(!(d>=0&&d<a0))return A.a(a,d)
a=a[d]
b1=a}else{if(!(d>=0&&d<a0))return A.a(a,d)
a1=a[d]
a2=d+1
if(!(a2<a0))return A.a(a,a2)
a2=(a1<<8|a[a2])>>>8
b1=a2}}else b1=255
b=e+1
if(!(e>=0&&e<s))return A.a(c9,e)
c9[e]=c3
e=b+1
if(!(b>=0&&b<s))return A.a(c9,b)
c9[b]=c3
b=e+1
if(!(e>=0&&e<s))return A.a(c9,e)
c9[e]=c3
e=b+1
if(!(b>=0&&b<s))return A.a(c9,b)
c9[b]=b1
break
case 4:a=n.c
a===$&&A.c(c7)
a0=a.length
if(i){if(!(d>=0&&d<a0))return A.a(a,d)
c4=a[d]}else{if(!(d>=0&&d<a0))return A.a(a,d)
a1=a[d]
a2=d+1
if(!(a2<a0))return A.a(a,a2)
c4=(a1<<8|a[a2])>>>8}a=m.c
a===$&&A.c(c7)
a0=a.length
if(i){if(!(d>=0&&d<a0))return A.a(a,d)
c5=a[d]}else{if(!(d>=0&&d<a0))return A.a(a,d)
a1=a[d]
a2=d+1
if(!(a2<a0))return A.a(a,a2)
c5=(a1<<8|a[a2])>>>8}a=l.c
a===$&&A.c(c7)
a0=a.length
if(i){if(!(d>=0&&d<a0))return A.a(a,d)
b3=a[d]}else{if(!(d>=0&&d<a0))return A.a(a,d)
a1=a[d]
a2=d+1
if(!(a2<a0))return A.a(a,a2)
b3=(a1<<8|a[a2])>>>8}a=d0.q(0,h?-1:3).c
a===$&&A.c(c7)
a0=a.length
if(i){if(!(d>=0&&d<a0))return A.a(a,d)
c6=a[d]}else{if(!(d>=0&&d<a0))return A.a(a,d)
a1=a[d]
a2=d+1
if(!(a2<a0))return A.a(a,a2)
c6=(a1<<8|a[a2])>>>8}if(j){a=k.c
a===$&&A.c(c7)
a0=a.length
if(i){if(!(d>=0&&d<a0))return A.a(a,d)
a=a[d]
b1=a}else{if(!(d>=0&&d<a0))return A.a(a,d)
a1=a[d]
a2=d+1
if(!(a2<a0))return A.a(a,a2)
a2=(a1<<8|a[a2])>>>8
b1=a2}}else b1=255
a=1-(255-c6)/255
c2=[B.c.aE(255*(1-(255-c4)/255)*a),B.c.aE(255*(1-(255-c5)/255)*a),B.c.aE(255*(1-(255-b3)/255)*a)]
b=e+1
a=c2[0]
if(!(e>=0&&e<s))return A.a(c9,e)
c9[e]=a
e=b+1
a=c2[1]
if(!(b>=0&&b<s))return A.a(c9,b)
c9[b]=a
b=e+1
a=c2[2]
if(!(e>=0&&e<s))return A.a(c9,e)
c9[e]=a
e=b+1
if(!(b>=0&&b<s))return A.a(c9,b)
c9[b]=b1
break
default:throw A.d(A.f("Unhandled color mode: "+A.v(d1)))}return c8},
hR:function hR(a){var _=this
_.e=_.d=null
_.f=$
_.w=_.r=null
_.y=_.x=$
_.z=null
_.Q=a
_.ch=_.ay=_.ax=_.at=$
_.b=_.a=0},
eR:function eR(){},
d1:function d1(a,b,c){var _=this
_.b=_.a=null
_.f=_.e=_.d=_.c=$
_.r=null
_.as=_.y=_.w=$
_.ay=a
_.ch=b
_.cx=$
_.cy=c},
nT(a,b){var s
switch(a){case"lsct":s=b.c-b.d
b.j()
if(s>=12){if(b.O(4)!=="8BIM")A.F(A.f("Invalid key in layer additional data"))
b.O(4)}if(s>=16)b.j()
return new A.eU()
default:return new A.d2(b)}},
c9:function c9(){},
d0:function d0(){this.a=null},
i1:function i1(){var _=this
_.e=_.d=null
_.b=_.a=0},
d8:function d8(){this.a=null
this.b=$},
i0:function i0(){},
i2:function i2(a){this.a=a
this.c=this.b=0},
f5:function f5(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.e=d},
ke(a,b,c){var s=new A.i3(b,a),r=t.x
s.sd6(A.H(b,null,!1,r))
s.sd4(A.H(b,null,!1,r))
return s},
i3:function i3(a,b){var _=this
_.a=a
_.c=b
_.d=0
_.f=_.e=null
_.r=$
_.x=_.w=null
_.y=0
_.z=2
_.as=0
_.at=null},
f6:function f6(a){var _=this
_.a=a
_.c=_.b=0
_.d=null
_.w=_.r=_.f=_.e=1
_.x=-1
_.y=!1
_.z=1
_.as=_.Q=$
_.ay=_.ax=0
_.CW=_.ch=null
_.cy=_.cx=$
_.dx=1
_.fr=_.dy=0
_.fy=null
_.k1=_.id=_.go=$
_.k3=_.k2=null},
i4:function i4(a){var _=this
_.e=null
_.r=a
_.b=_.a=0},
lh(){return new A.hB(new Uint8Array(4096))},
hB:function hB(a){var _=this
_.a=9
_.d=_.c=_.b=0
_.w=_.r=_.f=_.e=$
_.x=a
_.z=_.y=$
_.Q=null
_.as=$},
d9:function d9(){this.a=null
this.b=$},
kf(a,b){var s=new Int32Array(4),r=new Int32Array(4),q=new Int8Array(4),p=new Int8Array(4),o=A.H(8,null,!1,t.nX),n=A.H(4,null,!1,t.nk)
return new A.ic(a,b,new A.ij(),new A.io(),new A.ie(s,r),new A.iq(q,p),o,n,new Uint8Array(4))},
lN(a,b,c){if(c===0)if(a===0)return b===0?6:5
else return b===0?4:0
return c},
ic:function ic(a,b,c,d,e,f,g,h,i){var _=this
_.a=a
_.b=b
_.c=$
_.d=null
_.e=$
_.f=c
_.r=d
_.w=e
_.x=f
_.z=_.y=$
_.ax=_.at=_.as=_.Q=null
_.ch=_.ay=$
_.cx=_.CW=null
_.cy=$
_.db=g
_.dy=h
_.fr=null
_.fy=_.fx=$
_.go=null
_.id=i
_.p3=_.p2=_.p1=_.ok=_.k4=_.k3=_.k2=_.k1=$
_.R8=_.p4=null
_.x2=_.x1=_.to=_.ry=_.rx=_.RG=$
_.xr=null
_.y2=_.y1=0
_.ai=$
_.au=null
_.aL=_.ab=$
_.aZ=null
_.aM=$},
ir:function ir(){},
lK(a){var s=new A.dc(a)
s.b=254
s.c=0
s.d=-8
return s},
dc:function dc(a){var _=this
_.a=a
_.d=_.c=_.b=$
_.e=!1},
u(a,b,c){return B.a.X(B.a.i(a+2*b+c+2,2),32)},
oo(a){var s,r,q,p,o,n,m=a.a,l=a.d,k=l+-33,j=m.length
if(!(k>=0&&k<j))return A.a(m,k)
k=m[k]
s=l+-32
if(!(s>=0&&s<j))return A.a(m,s)
s=m[s]
r=l+-31
if(!(r>=0&&r<j))return A.a(m,r)
r=m[r]
k=A.u(k,s,r)
q=l+-30
if(!(q>=0&&q<j))return A.a(m,q)
q=m[q]
s=A.u(s,r,q)
p=l+-29
if(!(p>=0&&p<j))return A.a(m,p)
p=m[p]
r=A.u(r,q,p)
l+=-28
if(!(l>=0&&l<j))return A.a(m,l)
o=A.b([k,s,r,A.u(q,p,m[l])],t.t)
for(n=0;n<4;++n)a.b_(n*32,4,o)},
of(a){var s,r,q,p,o=a.a,n=a.d,m=n+-33,l=o.length
if(!(m>=0&&m<l))return A.a(o,m)
m=o[m]
s=n+-1
if(!(s>=0&&s<l))return A.a(o,s)
s=o[s]
r=n+31
if(!(r>=0&&r<l))return A.a(o,r)
r=o[r]
q=n+63
if(!(q>=0&&q<l))return A.a(o,q)
q=o[q]
n+=95
if(!(n>=0&&n<l))return A.a(o,n)
n=o[n]
p=A.j(a,null,0)
o=p.bR()
m=A.u(m,s,r)
if(0>=o.length)return A.a(o,0)
o[0]=16843009*m
p.d+=32
m=p.bR()
s=A.u(s,r,q)
if(0>=m.length)return A.a(m,0)
m[0]=16843009*s
p.d+=32
s=p.bR()
r=A.u(r,q,n)
if(0>=s.length)return A.a(s,0)
s[0]=16843009*r
p.d+=32
r=p.bR()
n=A.u(q,n,n)
if(0>=r.length)return A.a(r,0)
r[0]=16843009*n},
o8(a){var s,r,q,p,o,n,m
for(s=a.a,r=a.d,q=s.length,p=4,o=0;o<4;++o){n=r+(o-32)
if(!(n>=0&&n<q))return A.a(s,n)
n=s[n]
m=r+(-1+o*32)
if(!(m>=0&&m<q))return A.a(s,m)
p+=n+s[m]}p=B.a.i(p,3)
for(o=0;o<4;++o){s=a.a
r=a.d+o*32
J.aJ(s,r,r+4,p)}},
kg(a,b){var s,r,q,p,o,n,m,l=a.a,k=a.d+-33
if(!(k>=0&&k<l.length))return A.a(l,k)
s=255-l[k]
for(r=0,q=0;q<b;++q){l=a.a
k=a.d+(r-1)
if(!(k>=0&&k<l.length))return A.a(l,k)
p=s+l[k]
for(o=0;o<b;++o){l=$.af()
k=a.a
n=a.d
m=n+(-32+o)
if(!(m>=0&&m<k.length))return A.a(k,m)
m=p+k[m]
l.toString
if(!(m>=0&&m<766))return A.a(l,m)
J.n(k,n+(r+o),l[m])}r+=32}},
ol(a){A.kg(a,4)},
om(a){A.kg(a,8)},
ok(a){A.kg(a,16)},
oj(a){var s,r,q,p,o,n,m,l=a.a,k=a.d,j=k+-1,i=l.length
if(!(j>=0&&j<i))return A.a(l,j)
j=l[j]
s=k+31
if(!(s>=0&&s<i))return A.a(l,s)
s=l[s]
r=k+63
if(!(r>=0&&r<i))return A.a(l,r)
r=l[r]
q=k+95
if(!(q>=0&&q<i))return A.a(l,q)
q=l[q]
p=k+-33
if(!(p>=0&&p<i))return A.a(l,p)
p=l[p]
o=k+-32
if(!(o>=0&&o<i))return A.a(l,o)
o=l[o]
n=k+-31
if(!(n>=0&&n<i))return A.a(l,n)
n=l[n]
m=k+-30
if(!(m>=0&&m<i))return A.a(l,m)
m=l[m]
k+=-29
if(!(k>=0&&k<i))return A.a(l,k)
k=l[k]
a.h(0,96,A.u(s,r,q))
r=A.u(j,s,r)
a.h(0,97,r)
a.h(0,64,r)
s=A.u(p,j,s)
a.h(0,98,s)
a.h(0,65,s)
a.h(0,32,s)
j=A.u(o,p,j)
a.h(0,99,j)
a.h(0,66,j)
a.h(0,33,j)
a.h(0,0,j)
p=A.u(n,o,p)
a.h(0,67,p)
a.h(0,34,p)
a.h(0,1,p)
o=A.u(m,n,o)
a.h(0,35,o)
a.h(0,2,o)
a.h(0,3,A.u(k,m,n))},
oi(a){var s,r,q,p,o,n,m=a.a,l=a.d,k=l+-32,j=m.length
if(!(k>=0&&k<j))return A.a(m,k)
k=m[k]
s=l+-31
if(!(s>=0&&s<j))return A.a(m,s)
s=m[s]
r=l+-30
if(!(r>=0&&r<j))return A.a(m,r)
r=m[r]
q=l+-29
if(!(q>=0&&q<j))return A.a(m,q)
q=m[q]
p=l+-28
if(!(p>=0&&p<j))return A.a(m,p)
p=m[p]
o=l+-27
if(!(o>=0&&o<j))return A.a(m,o)
o=m[o]
n=l+-26
if(!(n>=0&&n<j))return A.a(m,n)
n=m[n]
l+=-25
if(!(l>=0&&l<j))return A.a(m,l)
l=m[l]
a.h(0,0,A.u(k,s,r))
s=A.u(s,r,q)
a.h(0,32,s)
a.h(0,1,s)
r=A.u(r,q,p)
a.h(0,64,r)
a.h(0,33,r)
a.h(0,2,r)
q=A.u(q,p,o)
a.h(0,96,q)
a.h(0,65,q)
a.h(0,34,q)
a.h(0,3,q)
p=A.u(p,o,n)
a.h(0,97,p)
a.h(0,66,p)
a.h(0,35,p)
o=A.u(o,n,l)
a.h(0,98,o)
a.h(0,67,o)
a.h(0,99,A.u(n,l,l))},
or(a){var s,r,q,p,o,n,m=a.a,l=a.d,k=l+-1,j=m.length
if(!(k>=0&&k<j))return A.a(m,k)
k=m[k]
s=l+31
if(!(s>=0&&s<j))return A.a(m,s)
s=m[s]
r=l+63
if(!(r>=0&&r<j))return A.a(m,r)
r=m[r]
q=l+-33
if(!(q>=0&&q<j))return A.a(m,q)
q=m[q]
p=l+-32
if(!(p>=0&&p<j))return A.a(m,p)
p=m[p]
o=l+-31
if(!(o>=0&&o<j))return A.a(m,o)
o=m[o]
n=l+-30
if(!(n>=0&&n<j))return A.a(m,n)
n=m[n]
l+=-29
if(!(l>=0&&l<j))return A.a(m,l)
l=m[l]
m=B.a.X(B.a.i(q+p+1,1),32)
a.h(0,65,m)
a.h(0,0,m)
m=B.a.X(B.a.i(p+o+1,1),32)
a.h(0,66,m)
a.h(0,1,m)
m=B.a.X(B.a.i(o+n+1,1),32)
a.h(0,67,m)
a.h(0,2,m)
a.h(0,3,B.a.X(B.a.i(n+l+1,1),32))
a.h(0,96,A.u(r,s,k))
a.h(0,64,A.u(s,k,q))
k=A.u(k,q,p)
a.h(0,97,k)
a.h(0,32,k)
q=A.u(q,p,o)
a.h(0,98,q)
a.h(0,33,q)
p=A.u(p,o,n)
a.h(0,99,p)
a.h(0,34,p)
a.h(0,35,A.u(o,n,l))},
oq(a){var s,r,q,p,o,n,m=a.a,l=a.d,k=l+-32,j=m.length
if(!(k>=0&&k<j))return A.a(m,k)
k=m[k]
s=l+-31
if(!(s>=0&&s<j))return A.a(m,s)
s=m[s]
r=l+-30
if(!(r>=0&&r<j))return A.a(m,r)
r=m[r]
q=l+-29
if(!(q>=0&&q<j))return A.a(m,q)
q=m[q]
p=l+-28
if(!(p>=0&&p<j))return A.a(m,p)
p=m[p]
o=l+-27
if(!(o>=0&&o<j))return A.a(m,o)
o=m[o]
n=l+-26
if(!(n>=0&&n<j))return A.a(m,n)
n=m[n]
l+=-25
if(!(l>=0&&l<j))return A.a(m,l)
l=m[l]
a.h(0,0,B.a.X(B.a.i(k+s+1,1),32))
m=B.a.X(B.a.i(s+r+1,1),32)
a.h(0,64,m)
a.h(0,1,m)
m=B.a.X(B.a.i(r+q+1,1),32)
a.h(0,65,m)
a.h(0,2,m)
m=B.a.X(B.a.i(q+p+1,1),32)
a.h(0,66,m)
a.h(0,3,m)
a.h(0,32,A.u(k,s,r))
s=A.u(s,r,q)
a.h(0,96,s)
a.h(0,33,s)
r=A.u(r,q,p)
a.h(0,97,r)
a.h(0,34,r)
q=A.u(q,p,o)
a.h(0,98,q)
a.h(0,35,q)
a.h(0,67,A.u(p,o,n))
a.h(0,99,A.u(o,n,l))},
oh(a){var s,r,q=a.a,p=a.d,o=p+-1,n=q.length
if(!(o>=0&&o<n))return A.a(q,o)
o=q[o]
s=p+31
if(!(s>=0&&s<n))return A.a(q,s)
s=q[s]
r=p+63
if(!(r>=0&&r<n))return A.a(q,r)
r=q[r]
p+=95
if(!(p>=0&&p<n))return A.a(q,p)
p=q[p]
a.h(0,0,B.a.X(B.a.i(o+s+1,1),32))
q=B.a.X(B.a.i(s+r+1,1),32)
a.h(0,32,q)
a.h(0,2,q)
q=B.a.X(B.a.i(r+p+1,1),32)
a.h(0,64,q)
a.h(0,34,q)
a.h(0,1,A.u(o,s,r))
s=A.u(s,r,p)
a.h(0,33,s)
a.h(0,3,s)
r=A.u(r,p,p)
a.h(0,65,r)
a.h(0,35,r)
a.h(0,99,p)
a.h(0,98,p)
a.h(0,97,p)
a.h(0,96,p)
a.h(0,66,p)
a.h(0,67,p)},
od(a){var s,r,q,p,o,n,m=a.a,l=a.d,k=l+-1,j=m.length
if(!(k>=0&&k<j))return A.a(m,k)
k=m[k]
s=l+31
if(!(s>=0&&s<j))return A.a(m,s)
s=m[s]
r=l+63
if(!(r>=0&&r<j))return A.a(m,r)
r=m[r]
q=l+95
if(!(q>=0&&q<j))return A.a(m,q)
q=m[q]
p=l+-33
if(!(p>=0&&p<j))return A.a(m,p)
p=m[p]
o=l+-32
if(!(o>=0&&o<j))return A.a(m,o)
o=m[o]
n=l+-31
if(!(n>=0&&n<j))return A.a(m,n)
n=m[n]
l+=-30
if(!(l>=0&&l<j))return A.a(m,l)
l=m[l]
m=B.a.X(B.a.i(k+p+1,1),32)
a.h(0,34,m)
a.h(0,0,m)
m=B.a.X(B.a.i(s+k+1,1),32)
a.h(0,66,m)
a.h(0,32,m)
m=B.a.X(B.a.i(r+s+1,1),32)
a.h(0,98,m)
a.h(0,64,m)
a.h(0,96,B.a.X(B.a.i(q+r+1,1),32))
a.h(0,3,A.u(o,n,l))
a.h(0,2,A.u(p,o,n))
o=A.u(k,p,o)
a.h(0,35,o)
a.h(0,1,o)
p=A.u(s,k,p)
a.h(0,67,p)
a.h(0,33,p)
k=A.u(r,s,k)
a.h(0,99,k)
a.h(0,65,k)
a.h(0,97,A.u(q,r,s))},
on(a){var s
for(s=0;s<16;++s)a.am(s*32,16,a,-32)},
oe(a){var s,r,q,p,o
for(s=0,r=16;r>0;--r){q=a.a
p=a.d
o=p+(s-1)
if(!(o>=0&&o<q.length))return A.a(q,o)
p+=s
J.aJ(q,p,p+16,q[o])
s+=32}},
ig(a,b){var s,r,q
for(s=0;s<16;++s){r=b.a
q=b.d+s*32
J.aJ(r,q,q+16,a)}},
o4(a){var s,r,q,p,o,n,m
for(s=a.a,r=a.d,q=s.length,p=16,o=0;o<16;++o){n=r+(-1+o*32)
if(!(n>=0&&n<q))return A.a(s,n)
n=s[n]
m=r+(o-32)
if(!(m>=0&&m<q))return A.a(s,m)
p+=n+s[m]}A.ig(B.a.i(p,5),a)},
o6(a){var s,r,q,p,o,n
for(s=a.a,r=a.d,q=s.length,p=8,o=0;o<16;++o){n=r+(-1+o*32)
if(!(n>=0&&n<q))return A.a(s,n)
p+=s[n]}A.ig(B.a.i(p,4),a)},
o5(a){var s,r,q,p,o,n
for(s=a.a,r=a.d,q=s.length,p=8,o=0;o<16;++o){n=r+(o-32)
if(!(n>=0&&n<q))return A.a(s,n)
p+=s[n]}A.ig(B.a.i(p,4),a)},
o7(a){A.ig(128,a)},
op(a){var s
for(s=0;s<8;++s)a.am(s*32,8,a,-32)},
og(a){var s,r,q,p,o
for(s=0,r=0;r<8;++r){q=a.a
p=a.d
o=p+(s-1)
if(!(o>=0&&o<q.length))return A.a(q,o)
p+=s
J.aJ(q,p,p+8,q[o])
s+=32}},
ih(a,b){var s,r,q
for(s=0;s<8;++s){r=b.a
q=b.d+s*32
J.aJ(r,q,q+8,a)}},
o9(a){var s,r,q,p,o,n,m
for(s=a.a,r=a.d,q=s.length,p=8,o=0;o<8;++o){n=r+(o-32)
if(!(n>=0&&n<q))return A.a(s,n)
n=s[n]
m=r+(-1+o*32)
if(!(m>=0&&m<q))return A.a(s,m)
p+=n+s[m]}A.ih(B.a.i(p,4),a)},
oa(a){var s,r,q,p,o,n
for(s=a.a,r=a.d,q=s.length,p=4,o=0;o<8;++o){n=r+(o-32)
if(!(n>=0&&n<q))return A.a(s,n)
p+=s[n]}A.ih(B.a.i(p,3),a)},
ob(a){var s,r,q,p,o,n
for(s=a.a,r=a.d,q=s.length,p=4,o=0;o<8;++o){n=r+(-1+o*32)
if(!(n>=0&&n<q))return A.a(s,n)
p+=s[n]}A.ih(B.a.i(p,3),a)},
oc(a){A.ih(128,a)},
bl(a,b,c,d,e){var s=b+c+d*32,r=a.a,q=a.d+s
if(!(q>=0&&q<r.length))return A.a(r,q)
q=r[q]+B.a.i(e,3)
if((q&-256)>>>0===0)r=q
else r=q<0?0:255
a.h(0,s,r)},
ii(a,b,c,d,e){A.bl(a,0,0,b,c+d)
A.bl(a,0,1,b,c+e)
A.bl(a,0,2,b,c-e)
A.bl(a,0,3,b,c-d)},
os(){var s,r,q
if(!$.lL){for(s=-255;s<=255;++s){r=$.fG()
q=255+s
r[q]=s<0?-s:s
$.jP()[q]=B.a.i(r[q],1)}for(s=-1020;s<=1020;++s){r=$.jQ()
if(s<-128)q=-128
else q=s>127?127:s
r[1020+s]=q}for(s=-112;s<=112;++s){r=$.fH()
if(s<-16)q=-16
else q=s>15?15:s
r[112+s]=q}for(s=-255;s<=510;++s){r=$.af()
if(s<0)q=0
else q=s>255?255:s
r[255+s]=q}$.lL=!0}},
id:function id(){},
o3(){var s,r=J.ah(3,t.D)
for(s=0;s<3;++s)r[s]=new Uint8Array(11)
return new A.db(r)},
oH(){var s,r,q,p,o=new Uint8Array(3),n=J.ah(4,t.ac)
for(s=t.aO,r=0;r<4;++r){q=J.ah(8,s)
for(p=0;p<8;++p)q[p]=A.o3()
n[r]=q}B.e.ak(o,0,3,255)
return new A.ip(o,n)},
ij:function ij(){this.d=$},
io:function io(){},
iq:function iq(a,b){var _=this
_.b=_.a=!1
_.c=!0
_.d=a
_.e=b},
db:function db(a){this.a=a},
ip:function ip(a,b){this.a=a
this.b=b},
ie:function ie(a,b){var _=this
_.a=$
_.b=null
_.d=_.c=$
_.e=a
_.f=b},
aW:function aW(){var _=this
_.b=_.a=0
_.c=!1
_.d=0},
de:function de(){this.b=this.a=0},
fg:function fg(a,b,c){this.a=a
this.b=b
this.c=c},
df:function df(a,b){var _=this
_.a=a
_.b=$
_.c=b
_.e=_.d=null
_.f=$},
dg:function dg(a,b,c){this.a=a
this.b=b
this.c=c},
kh(a,b){var s,r=A.b([],t.W),q=A.b([],t.ip),p=new Uint32Array(2),o=new A.fe(a,p)
p=o.d=A.z(p.buffer,0,null)
s=a.t()
if(0>=p.length)return A.a(p,0)
p[0]=s
s=a.t()
if(1>=p.length)return A.a(p,1)
p[1]=s
s=a.t()
if(2>=p.length)return A.a(p,2)
p[2]=s
s=a.t()
if(3>=p.length)return A.a(p,3)
p[3]=s
s=a.t()
if(4>=p.length)return A.a(p,4)
p[4]=s
s=a.t()
if(5>=p.length)return A.a(p,5)
p[5]=s
s=a.t()
if(6>=p.length)return A.a(p,6)
p[6]=s
s=a.t()
if(7>=p.length)return A.a(p,7)
p[7]=s
return new A.dd(o,b,r,q)},
bK(a,b){return B.a.i(a+B.a.B(1,b)-1,b)},
dd:function dd(a,b,c,d){var _=this
_.b=a
_.c=b
_.d=null
_.r=_.f=_.e=0
_.w=null
_.z=_.y=_.x=0
_.Q=null
_.as=0
_.at=c
_.ax=d
_.ay=0
_.ch=null
_.CW=$
_.db=_.cy=_.cx=null},
eo:function eo(a,b,c,d){var _=this
_.b=a
_.c=b
_.d=null
_.r=_.f=_.e=0
_.w=null
_.z=_.y=_.x=0
_.Q=null
_.as=0
_.at=c
_.ax=d
_.ay=0
_.ch=null
_.CW=$
_.db=_.cy=_.cx=null},
fe:function fe(a,b){var _=this
_.a=0
_.b=a
_.c=b
_.d=$},
ik:function ik(a,b){this.a=a
this.b=b},
il(a,b,c){var s
if(!(b>=0&&b<a.length))return A.a(a,b)
s=a[b]
a[b]=(((s&4278255360)>>>0)+((c&4278255360)>>>0)&4278255360|(s&16711935)+(c&16711935)&16711935)>>>0},
aX(a,b){return((a^b)>>>1&2139062143)+((a&b)>>>0)},
bJ(a){if(a<0)return 0
if(a>255)return 255
return a},
im(a,b,c){return Math.abs(b-c)-Math.abs(a-c)},
ot(a,b,c){return 4278190080},
ou(a,b,c){return b},
oz(a,b,c){if(!(c>=0&&c<a.length))return A.a(a,c)
return a[c]},
oA(a,b,c){var s=c+1
if(!(s>=0&&s<a.length))return A.a(a,s)
return a[s]},
oB(a,b,c){var s=c-1
if(!(s>=0&&s<a.length))return A.a(a,s)
return a[s]},
oC(a,b,c){var s,r,q=a.length
if(!(c>=0&&c<q))return A.a(a,c)
s=a[c]
r=c+1
if(!(r<q))return A.a(a,r)
return A.aX(A.aX(b,a[r]),s)},
oD(a,b,c){var s=c-1
if(!(s>=0&&s<a.length))return A.a(a,s)
return A.aX(b,a[s])},
oE(a,b,c){if(!(c>=0&&c<a.length))return A.a(a,c)
return A.aX(b,a[c])},
oF(a,b,c){var s=c-1,r=a.length
if(!(s>=0&&s<r))return A.a(a,s)
s=a[s]
if(!(c>=0&&c<r))return A.a(a,c)
return A.aX(s,a[c])},
oG(a,b,c){var s,r,q=a.length
if(!(c>=0&&c<q))return A.a(a,c)
s=a[c]
r=c+1
if(!(r<q))return A.a(a,r)
return A.aX(s,a[r])},
ov(a,b,c){var s,r,q=c-1,p=a.length
if(!(q>=0&&q<p))return A.a(a,q)
q=a[q]
if(!(c>=0&&c<p))return A.a(a,c)
s=a[c]
r=c+1
if(!(r<p))return A.a(a,r)
r=a[r]
return A.aX(A.aX(b,q),A.aX(s,r))},
ow(a,b,c){var s,r,q=a.length
if(!(c>=0&&c<q))return A.a(a,c)
s=a[c]
r=c-1
if(!(r>=0&&r<q))return A.a(a,r)
r=a[r]
return A.im(s>>>24,b>>>24,r>>>24)+A.im(s>>>16&255,b>>>16&255,r>>>16&255)+A.im(s>>>8&255,b>>>8&255,r>>>8&255)+A.im(s&255,b&255,r&255)<=0?s:b},
ox(a,b,c){var s,r,q=a.length
if(!(c>=0&&c<q))return A.a(a,c)
s=a[c]
r=c-1
if(!(r>=0&&r<q))return A.a(a,r)
r=a[r]
return(A.bJ((b>>>24)+(s>>>24)-(r>>>24))<<24|A.bJ((b>>>16&255)+(s>>>16&255)-(r>>>16&255))<<16|A.bJ((b>>>8&255)+(s>>>8&255)-(r>>>8&255))<<8|A.bJ((b&255)+(s&255)-(r&255)))>>>0},
oy(a,b,c){var s,r,q,p,o,n=a.length
if(!(c>=0&&c<n))return A.a(a,c)
s=a[c]
r=c-1
if(!(r>=0&&r<n))return A.a(a,r)
r=a[r]
q=A.aX(b,s)
s=q>>>24
n=q>>>16&255
p=q>>>8&255
o=q>>>0&255
return(A.bJ(s+B.a.F(s-(r>>>24),2))<<24|A.bJ(n+B.a.F(n-(r>>>16&255),2))<<16|A.bJ(p+B.a.F(p-(r>>>8&255),2))<<8|A.bJ(o+B.a.F(o-(r&255),2)))>>>0},
ff:function ff(){var _=this
_.c=_.b=_.a=0
_.d=null
_.e=0},
is:function is(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.f=_.e=_.d=0
_.r=1
_.w=!1
_.x=$
_.y=!1},
di:function di(){},
ep:function ep(){this.r=1
this.x=this.w=$},
l2(){var s=new Uint8Array(128),r=new Int16Array(128)
s=new A.ea(s,r,new Int16Array(128))
s.cP(0)
return s},
nw(){var s,r=J.ah(5,t.gP)
for(s=0;s<5;++s)r[s]=A.l2()
return new A.c0(r)},
ea:function ea(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=$
_.f=_.e=0},
c0:function c0(a){this.a=a},
dj:function dj(a){var _=this
_.e=_.d=!1
_.f=0
_.z=a
_.as=_.Q=0
_.at=null
_.b=_.a=_.ch=_.ay=0},
cK:function cK(a){var _=this
_.e=_.d=!1
_.f=0
_.z=a
_.as=_.Q=0
_.at=null
_.b=_.a=_.ch=_.ay=0},
dh:function dh(){this.b=this.a=null},
e9:function e9(a){var _=this
_.a=a
_.e=_.d=_.c=_.b=null},
l1(a,b,c){switch(b){case 1:if(c===8)return new Int8Array(a)
else if(c===16)return new Int16Array(a)
else if(c===32)return new Int32Array(a)
break
case 0:if(c===8)return new Uint8Array(a)
else if(c===16)return new Uint16Array(a)
else if(c===32)return new Uint32Array(a)
break
case 3:if(c===16)return new Uint16Array(a)
else if(c===32)return new Float32Array(a)
else if(c===64)return new Float64Array(a)
break}throw A.d(A.da(null))},
h9(a,b,c,d,e){return new A.cF(a,b,c,d,e,A.l1(b*c,d,e))},
cF:function cF(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
q7(a1,a2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b=new A.jD(new A.jE()),a=A.T(a1.gkI(a1),a1.gb9(a1),B.f,null,null),a0=a.aw()
if(!(a1.b!=null||a1.c!=null||a1.d!=null))throw A.d(A.f("Only RGB[A] images are currently supported."))
s=Math.pow(2,B.c.p(a2+2.47393,-20,20))
r=a0.length
q=a1.a
p=0
o=0
while(!0){if(q.a===0)n=0
else{n=q.gaG()
n=n.b.$1(J.dP(n.a)).c}if(!(p<n))break
m=0
while(!0){if(q.a===0)n=0
else{n=q.gaG()
n=n.b.$1(J.dP(n.a)).b}if(!(m<n))break
n=a1.b
if(n!=null)if(n.d===3){n=n.bV(m,p)
l=n}else{k=p*n.b+m
n=n.f
if(!(k>=0&&k<n.length))return A.a(n,k)
n=A.o(n[k])
l=n}else l=0
if(q.a===1)j=l
else{n=a1.c
if(n!=null){if(n.d===3)n=n.bV(m,p)
else{k=p*n.b+m
n=n.f
if(!(k>=0&&k<n.length))return A.a(n,k)
n=A.o(n[k])}j=n}else j=0}if(q.a===1)i=l
else{n=a1.d
if(n!=null){if(n.d===3)n=n.bV(m,p)
else{k=p*n.b+m
n=n.f
if(!(k>=0&&k<n.length))return A.a(n,k)
n=A.o(n[k])}i=n}else i=0}if(l==1/0||l==-1/0||isNaN(l))l=0
if(j==1/0||j==-1/0||isNaN(j))j=0
if(i==1/0||i==-1/0||isNaN(i))i=0
h=b.$2(l,s)
g=b.$2(j,s)
f=b.$2(i,s)
e=Math.max(h,Math.max(g,f))
if(e>255){h=255*(h/e)
g=255*(g/e)
f=255*(f/e)}d=o+1
n=B.c.m(B.c.p(h,0,255))
if(!(o>=0&&o<r))return A.a(a0,o)
a0[o]=n
o=d+1
n=B.c.m(B.c.p(g,0,255))
if(!(d>=0&&d<r))return A.a(a0,d)
a0[d]=n
d=o+1
n=B.c.m(B.c.p(f,0,255))
if(!(o>=0&&o<r))return A.a(a0,o)
a0[o]=n
n=a1.e
if(n!=null){c=n.bV(m,p)
if(c==1/0||c==-1/0||isNaN(c))c=1
o=d+1
n=B.c.m(B.c.p(c*255,0,255))
if(!(d>=0&&d<r))return A.a(a0,d)
a0[d]=n}else{o=d+1
if(!(d>=0&&d<r))return A.a(a0,d)
a0[d]=255}++m}++p}return a},
jE:function jE(){},
jD:function jD(a){this.a=a},
hb:function hb(a,b){this.a=a
this.b=b},
hc:function hc(a,b,c){this.a=a
this.b=b
this.c=c},
T(a,b,c,d,e){return new A.c3(a,b,c,0,0,0,B.aZ,B.aO,new Uint32Array(a*b),A.kY(d),e)},
jV(a){var s,r=new A.c3(a.a,a.b,a.c,a.d,a.e,a.f,a.r,a.w,B.n.cq(a.x,0),A.kY(a.y),a.z),q=a.Q
if(q!=null){s=t.N
r.seW(A.lf(q,s,s))}return r},
h3:function h3(a,b){this.a=a
this.b=b},
dU:function dU(a,b){this.a=a
this.b=b},
fS:function fS(a,b){this.a=a
this.b=b},
fZ:function fZ(a,b){this.a=a
this.b=b},
c3:function c3(a,b,c,d,e,f,g,h,i,j,k){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.x=i
_.y=j
_.z=k
_.Q=null},
hm:function hm(a,b){this.a=a
this.b=b},
hl:function hl(){},
f(a){return new A.hg(a)},
hg:function hg(a){this.a=a},
mp(a9,b0,b1,b2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8
if(b1===B.b_)return b0.f4(a9)
s=b1.a
if(!(s<5))return A.a(B.as,s)
r=B.as[s]
q=a9.b
p=a9.a
o=new Uint8Array(A.b_(a9.aw()))
s=p*q
n=new Uint8Array(s)
m=b0.a
m===$&&A.c("colorMap")
for(l=r.length,k=o.length,j=m.length,i=0,h=0;h<q;++h)for(g=0;g!==p;++g,++i){f=i*4
if(!(f<k))return A.a(o,f)
e=o[f]
d=f+1
if(!(d<k))return A.a(o,d)
c=o[d]
d=f+2
if(!(d<k))return A.a(o,d)
b=o[d]
f=b0.e0(b,c,e)
if(!(i>=0&&i<s))return A.a(n,i)
n[i]=f
f*=3
if(!(f>=0&&f<j))return A.a(m,f)
a=m[f]
d=f+1
if(!(d<j))return A.a(m,d)
a0=m[d]
d=f+2
if(!(d<j))return A.a(m,d)
a1=e-a
a2=c-a0
a3=b-m[d]
if(a1===0&&a2===0&&a3===0)continue
for(a4=0;a4!==l;++a4){if(!(a4>=0&&a4<l))return A.a(r,a4)
d=r[a4]
a5=B.c.m(d[1])
a6=B.c.m(d[2])
a7=a5+g
if(a7>=0)if(a7<p){a7=a6+h
a7=a7>=0&&a7<q}else a7=!1
else a7=!1
if(a7){a8=d[0]
f=(i+a5+a6*p)*4
if(!(f>=0&&f<k))return A.a(o,f)
B.e.h(o,f,Math.max(0,Math.min(255,B.c.m(o[f]+a1*a8))))
d=f+1
if(!(d<k))return A.a(o,d)
B.e.h(o,d,Math.max(0,Math.min(255,B.c.m(o[d]+a2*a8))))
d=f+2
if(!(d<k))return A.a(o,d)
B.e.h(o,d,Math.max(0,Math.min(255,B.c.m(o[d]+a3*a8))))}}}return n},
e0:function e0(a,b){this.a=a
this.b=b},
l(a,b,c,d){return new A.a3(a,d,c==null?a.length:d+c,d,b)},
j(a,b,c){var s=a.a,r=a.d+c,q=a.b,p=b==null?a.c:r+b
return new A.a3(s,q,p,r,a.e)},
a3:function a3(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
cL:function cL(a,b){this.a=a
this.b=b},
lj(a,b){var s=new A.hF(b,new Int32Array(256))
s.ia(256)
s.ii(a)
s.hW()
s.ic()
s.hi()
return s},
hF:function hF(a,b){var _=this
_.a=$
_.b=a
_.c=16
_.d=3
_.f=_.e=$
_.r=null
_.Q=_.z=_.y=_.x=_.w=$
_.as=b
_.ax=_.at=$},
aq(a,b){return new A.eL(a,new Uint8Array(b))},
eL:function eL(a,b){this.a=0
this.b=a
this.c=b},
hU:function hU(){},
nJ(a){var s=B.d.k5(a,".")
if(s<0||s+1>=a.length)return a
return B.d.dk(a,s+1).toLowerCase()},
hD:function hD(a,b){this.a=a
this.b=b},
pV(a,b){var s,r,q,p=t.dd.a(self),o=new MessageChannel(),n=t.p,m=new A.ix(A.J(n,t.g9),new A.iu(new A.jw(o,p),A.J(n,t.m)))
n=o.port1
s=t.m1
r=s.a(new A.jx(m))
t.Z.a(null)
q=t.e
A.iQ(n,"message",r,!1,q)
A.iQ(p,"message",s.a(new A.jy(m,o,a)),!1,q)},
jw:function jw(a,b){this.a=a
this.b=b},
jx:function jx(a){this.a=a},
jy:function jy(a,b,c){this.a=a
this.b=b
this.c=c},
iM:function iM(){},
fp:function fp(){this.a=null},
j6:function j6(a){this.a=a},
f7:function f7(){},
i5:function i5(a){this.a=a},
n8(a){var s,r
if(a==null)return null
s=J.ae(a)
r=A.kr(s.q(a,1))
return new A.bV(A.o(s.q(a,0)),r)},
bV:function bV(a,b){var _=this
_.a=a
_.b=null
_.c=b
_.d=null},
kc(){var s=$.ac
if(s==null){s=$.ac=new A.hW(A.b([],t.t))
s.d=$.bf}return s},
lB(a){var s=$.ac
if(s==null)s=null
else{s=s.c
s=s==null?null:s.c8(1000,a)}return s},
hW:function hW(a){var _=this
_.a=2000
_.b=a
_.c=null
_.d=!1
_.f=_.e=null},
aI(a){var s
A.lB("creating new SquadronError: "+a)
s=new A.d5(a)
s.fF(a,null)
return s},
d5:function d5(a){this.a=a
this.b=null},
kb(a,b){var s,r,q=null
if(a instanceof A.d5)return a
else if(a instanceof A.ce){s=A.lO(a,q)
s.c=null
return A.lO(s,q)}else if(t.on.b(a)){s=a.a
r=new A.f3(a.x,s,q,q,q)
r.cs(s,q,q,q)
return r}else return A.ki(J.bR(a),q,b,q)},
be:function be(){},
nW(a){if(a<1)return"ALL"
if(a<300)return"DEBUG"
if(a<400)return"FINEST"
if(a<500)return"FINER"
if(a<700)return"FINE"
if(a<800)return"CONFIG"
if(a<900)return"INFO"
if(a<1000)return"WARNING"
if(a<1200)return"SEVERE"
if(a<2000)return"SHOUT"
return"OFF"},
dS:function dS(){},
fM:function fM(){},
fN:function fN(){},
fO:function fO(){},
fP:function fP(){},
eM:function eM(a,b){this.b=a
this.a=b},
ki(a,b,c,d){var s=new A.ce(a,c,d,b)
s.cs(a,b,c,d)
return s},
n9(a,b,c,d){var s=b==null?"The task has been cancelled":b,r=new A.bW(s,c,d,a)
r.cs(s,a,c,d)
return r},
lO(a,b){a.d=b
return a},
ce:function ce(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
bW:function bW(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
f3:function f3(a,b,c,d,e){var _=this
_.x=a
_.a=b
_.b=c
_.c=d
_.d=e},
lP(a){var s,r,q,p,o,n,m,l,k,j,i
if(a==null)return null
s=a.q(0,"a")
r=A.o(a.q(0,"b"))
q=A.kr(a.q(0,"f"))
p=a.q(0,"c")
if(p==null)p=B.av
t.j.a(p)
o=A.m6(a.q(0,"g"))
n=A.n8(t.lH.a(a.q(0,"d")))
m=A.m6(a.q(0,"e"))
l=a.q(0,"h")
l=A.m5(l==null?!0:l)
if(s==null)s=null
else{k=new A.fp()
k.a=t.hk.a(s)
s=k}j=new A.aC(s,n,m,r,p,q,o,l)
i=a.q(0,"i")
if(i!=null)j.x=1000*Date.now()-A.o(i)
return j},
aC:function aC(a,b,c,d,e,f,g,h){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.x=null},
iw(a){return new A.bL(!1,null,null,t.R.b(a)&&!t.j.b(a)?J.n2(a):a)},
bL:function bL(a,b,c,d){var _=this
_.a=a
_.b=b
_.d=c
_.e=d},
b8:function b8(a,b,c){var _=this
_.e=a
_.f=0
_.a=b
_.b=null
_.c=c
_.d=null},
hV:function hV(){this.a=0},
iu:function iu(a,b){var _=this
_.a=a
_.b=!1
_.c=0
_.d=b
_.e=null
_.f=0},
iv:function iv(a){this.a=a},
ix:function ix(a,b){this.a=a
this.b=b},
iy:function iy(){},
iB:function iB(a,b,c){this.a=a
this.b=b
this.c=c},
iz:function iz(a,b){this.a=a
this.b=b},
iA:function iA(a,b,c){this.a=a
this.b=b
this.c=c},
nZ(a){throw A.d(A.Z("Uint64List not supported on the web."))},
lI(a,b){var s
A.bO(a,b,null)
s=B.a.F(a.byteLength-b,4)
return new Uint32Array(a,b,s)},
nr(a){var s
A.bO(a,0,null)
s=B.a.F(a.byteLength-0,4)
return new Float32Array(a,0,s)},
ns(a){return a.kN(0,0,null)},
mw(a){if(typeof dartPrint=="function"){dartPrint(a)
return}if(typeof console=="object"&&typeof console.log!="undefined"){console.log(a)
return}if(typeof window=="object")return
if(typeof print=="function"){print(a)
return}throw"Unable to print message: "+String(a)},
q_(a){var s,r,q,p,o,n,m=a.length
for(s=m,r=1,q=0,p=0;s>0;){o=3800>s?s:3800
s-=o
for(;--o,o>=0;p=n){n=p+1
if(!(p>=0&&p<m))return A.a(a,p)
r+=a[p]&255
q+=r}r=B.a.I(r,65521)
q=B.a.I(q,65521)}return(q<<16|r)>>>0},
at(a,b){var s,r,q,p=J.ae(a),o=p.gv(a)
b^=4294967295
for(s=0;o>=8;){r=s+1
q=p.q(a,s)
if(typeof q!=="number")return A.D(q)
b=B.k[(b^q)&255]^b>>>8
s=r+1
q=p.q(a,r)
if(typeof q!=="number")return A.D(q)
b=B.k[(b^q)&255]^b>>>8
r=s+1
q=p.q(a,s)
if(typeof q!=="number")return A.D(q)
b=B.k[(b^q)&255]^b>>>8
s=r+1
q=p.q(a,r)
if(typeof q!=="number")return A.D(q)
b=B.k[(b^q)&255]^b>>>8
r=s+1
q=p.q(a,s)
if(typeof q!=="number")return A.D(q)
b=B.k[(b^q)&255]^b>>>8
s=r+1
q=p.q(a,r)
if(typeof q!=="number")return A.D(q)
b=B.k[(b^q)&255]^b>>>8
r=s+1
q=p.q(a,s)
if(typeof q!=="number")return A.D(q)
b=B.k[(b^q)&255]^b>>>8
s=r+1
q=p.q(a,r)
if(typeof q!=="number")return A.D(q)
b=B.k[(b^q)&255]^b>>>8
o-=8}if(o>0)do{r=s+1
q=p.q(a,s)
if(typeof q!=="number")return A.D(q)
b=B.k[(b^q)&255]^b>>>8
if(--o,o>0){s=r
continue}else break}while(!0)
return(b^4294967295)>>>0},
aE(a,b,c,d){return(B.c.m(B.a.p(d,0,255))<<24|B.c.m(B.a.p(c,0,255))<<16|B.c.m(B.a.p(b,0,255))<<8|B.c.m(B.a.p(a,0,255)))>>>0},
q6(a){var s,r,q,p,o,n,m,l=a.aw()
for(s=l.length,r=0;r<s;r+=4){q=l[r]
p=r+1
if(!(p<s))return A.a(l,p)
o=l[p]
n=r+2
if(!(n<s))return A.a(l,n)
m=B.c.aE(0.299*q+0.587*o+0.114*l[n])
l[r]=m
l[p]=m
l[n]=m}return a},
np(a6,a7,a8,a9,b0,b1,b2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4=b2<16384,a5=a8>b0?b0:a8
for(s=1;s<=a5;)s=s<<1>>>0
s=s>>>1
r=s>>>1
q=A.b([0,0],t.t)
for(p=a6.length,o=s,s=r;s>=1;o=s,s=r){n=a7+b1*(b0-o)
m=b1*s
l=b1*o
k=a9*s
j=a9*o
for(i=(a8&s)>>>0!==0,h=a9*(a8-o),g=a7;g<=n;g+=l){f=g+h
for(e=g;e<=f;e+=j){d=e+k
c=e+m
b=c+k
if(a4){if(!(e>=0&&e<p))return A.a(a6,e)
a=a6[e]
if(!(c>=0&&c<p))return A.a(a6,c)
A.cA(a,a6[c],q)
a0=q[0]
a1=q[1]
if(!(d>=0&&d<p))return A.a(a6,d)
a=a6[d]
if(!(b>=0&&b<p))return A.a(a6,b)
A.cA(a,a6[b],q)
a2=q[0]
a3=q[1]
A.cA(a0,a2,q)
a6[e]=q[0]
a6[d]=q[1]
A.cA(a1,a3,q)
a6[c]=q[0]
a6[b]=q[1]}else{if(!(e>=0&&e<p))return A.a(a6,e)
a=a6[e]
if(!(c>=0&&c<p))return A.a(a6,c)
A.cB(a,a6[c],q)
a0=q[0]
a1=q[1]
if(!(d>=0&&d<p))return A.a(a6,d)
a=a6[d]
if(!(b>=0&&b<p))return A.a(a6,b)
A.cB(a,a6[b],q)
a2=q[0]
a3=q[1]
A.cB(a0,a2,q)
a6[e]=q[0]
a6[d]=q[1]
A.cB(a1,a3,q)
a6[c]=q[0]
a6[b]=q[1]}}if(i){c=e+m
if(a4){if(!(e>=0&&e<p))return A.a(a6,e)
a=a6[e]
if(!(c>=0&&c<p))return A.a(a6,c)
A.cA(a,a6[c],q)
a0=q[0]
a6[c]=q[1]}else{if(!(e>=0&&e<p))return A.a(a6,e)
a=a6[e]
if(!(c>=0&&c<p))return A.a(a6,c)
A.cB(a,a6[c],q)
a0=q[0]
a6[c]=q[1]}if(!(e>=0&&e<p))return A.a(a6,e)
a6[e]=a0}}if((b0&s)>>>0!==0){f=g+h
for(e=g;e<=f;e+=j){d=e+k
if(a4){if(!(e>=0&&e<p))return A.a(a6,e)
i=a6[e]
if(!(d>=0&&d<p))return A.a(a6,d)
A.cA(i,a6[d],q)
a0=q[0]
a6[d]=q[1]}else{if(!(e>=0&&e<p))return A.a(a6,e)
i=a6[e]
if(!(d>=0&&d<p))return A.a(a6,d)
A.cB(i,a6[d],q)
a0=q[0]
a6[d]=q[1]}if(!(e>=0&&e<p))return A.a(a6,e)
a6[e]=a0}}r=s>>>1}},
cA(a,b,c){var s,r,q,p,o,n=$.a6()
n[0]=a
s=$.ag()
r=s.length
if(0>=r)return A.a(s,0)
q=s[0]
n[0]=b
if(0>=r)return A.a(s,0)
p=s[0]
o=q+(p&1)+B.a.i(p,1)
B.b.h(c,0,o)
B.b.h(c,1,o-p)},
cB(a,b,c){var s=a-B.a.i(b,1)&65535
B.b.h(c,1,s)
B.b.h(c,0,b+s-32768&65535)},
jB(a){var s,r,q,p,o,n,m,l=null
t.L.a(a)
if(A.lc().kH(a))return new A.c7()
s=new A.c8()
if(s.bm(a))return s
r=new A.cD()
r.b=A.l(a,!1,l,0)
r.a=new A.e8(A.b([],t.b))
if(r.dS())return r
q=new A.dh()
if(q.bm(a))return q
p=new A.d9()
if(p.ee(A.l(a,!1,l,0))!=null)return p
if(A.lu(a).d===943870035)return new A.d0()
if(A.no(a))return new A.cz()
if(A.fR(A.l(a,!1,l,0)))return new A.bT()
o=new A.d8()
if(o.bm(a))return o
n=new A.cG()
m=A.l(a,!1,l,0)
n.a=m
m=A.l3(m)
n.b=m
if(m!=null)return n
return l},
qi(a4,a5,a6,a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3
if($.kt==null){s=$.kt=new Uint8Array(768)
for(r=-256;r<0;++r)s[256+r]=0
for(r=0;r<256;++r)s[256+r]=r
for(r=256;r<512;++r)s[256+r]=255}for(r=0;r<64;++r){s=a5[r]
q=a4[r]
if(!(r<64))return A.a(a7,r)
a7[r]=s*q}for(p=0,r=0;r<8;++r,p+=8){s=1+p
if(!(s<64))return A.a(a7,s)
q=a7[s]
if(q===0){o=2+p
if(!(o<64))return A.a(a7,o)
if(a7[o]===0){o=3+p
if(!(o<64))return A.a(a7,o)
if(a7[o]===0){o=4+p
if(!(o<64))return A.a(a7,o)
if(a7[o]===0){o=5+p
if(!(o<64))return A.a(a7,o)
if(a7[o]===0){o=6+p
if(!(o<64))return A.a(a7,o)
if(a7[o]===0){o=7+p
if(!(o<64))return A.a(a7,o)
o=a7[o]===0}else o=!1}else o=!1}else o=!1}else o=!1}else o=!1}else o=!1
if(o){if(!(p<64))return A.a(a7,p)
s=B.a.i(5793*a7[p]+512,10)
n=(s&2147483647)-((s&2147483648)>>>0)
if(!(p<64))return A.a(a7,p)
a7[p]=n
s=p+1
if(!(s<64))return A.a(a7,s)
a7[s]=n
s=p+2
if(!(s<64))return A.a(a7,s)
a7[s]=n
s=p+3
if(!(s<64))return A.a(a7,s)
a7[s]=n
s=p+4
if(!(s<64))return A.a(a7,s)
a7[s]=n
s=p+5
if(!(s<64))return A.a(a7,s)
a7[s]=n
s=p+6
if(!(s<64))return A.a(a7,s)
a7[s]=n
s=p+7
if(!(s<64))return A.a(a7,s)
a7[s]=n
continue}if(!(p<64))return A.a(a7,p)
o=B.a.i(5793*a7[p]+128,8)
m=(o&2147483647)-((o&2147483648)>>>0)
o=4+p
if(!(o<64))return A.a(a7,o)
l=B.a.i(5793*a7[o]+128,8)
k=(l&2147483647)-((l&2147483648)>>>0)
l=2+p
if(!(l<64))return A.a(a7,l)
j=a7[l]
i=6+p
if(!(i<64))return A.a(a7,i)
h=a7[i]
g=7+p
if(!(g<64))return A.a(a7,g)
f=a7[g]
e=B.a.i(2896*(q-f)+128,8)
d=(e&2147483647)-((e&2147483648)>>>0)
f=B.a.i(2896*(q+f)+128,8)
c=(f&2147483647)-((f&2147483648)>>>0)
f=3+p
if(!(f<64))return A.a(a7,f)
q=a7[f]<<4
b=(q&2147483647)-((q&2147483648)>>>0)
q=5+p
if(!(q<64))return A.a(a7,q)
e=a7[q]<<4
a=(e&2147483647)-((e&2147483648)>>>0)
e=B.a.i(m-k+1,1)
n=(e&2147483647)-((e&2147483648)>>>0)
e=B.a.i(m+k+1,1)
m=(e&2147483647)-((e&2147483648)>>>0)
e=B.a.i(j*3784+h*1567+128,8)
e=(e&2147483647)-((e&2147483648)>>>0)
a0=B.a.i(j*1567-h*3784+128,8)
j=(a0&2147483647)-((a0&2147483648)>>>0)
a0=B.a.i(d-a+1,1)
a0=(a0&2147483647)-((a0&2147483648)>>>0)
a1=B.a.i(d+a+1,1)
d=(a1&2147483647)-((a1&2147483648)>>>0)
a1=B.a.i(c+b+1,1)
a1=(a1&2147483647)-((a1&2147483648)>>>0)
a2=B.a.i(c-b+1,1)
b=(a2&2147483647)-((a2&2147483648)>>>0)
a2=B.a.i(m-e+1,1)
a2=(a2&2147483647)-((a2&2147483648)>>>0)
e=B.a.i(m+e+1,1)
m=(e&2147483647)-((e&2147483648)>>>0)
e=B.a.i(n-j+1,1)
e=(e&2147483647)-((e&2147483648)>>>0)
a3=B.a.i(n+j+1,1)
k=(a3&2147483647)-((a3&2147483648)>>>0)
a3=B.a.i(d*2276+a1*3406+2048,12)
n=(a3&2147483647)-((a3&2147483648)>>>0)
a1=B.a.i(d*3406-a1*2276+2048,12)
d=(a1&2147483647)-((a1&2147483648)>>>0)
a1=B.a.i(b*799+a0*4017+2048,12)
a1=(a1&2147483647)-((a1&2147483648)>>>0)
a0=B.a.i(b*4017-a0*799+2048,12)
b=(a0&2147483647)-((a0&2147483648)>>>0)
if(!(p<64))return A.a(a7,p)
a7[p]=m+n
if(!(g<64))return A.a(a7,g)
a7[g]=m-n
if(!(s<64))return A.a(a7,s)
a7[s]=k+a1
if(!(i<64))return A.a(a7,i)
a7[i]=k-a1
if(!(l<64))return A.a(a7,l)
a7[l]=e+b
if(!(q<64))return A.a(a7,q)
a7[q]=e-b
if(!(f<64))return A.a(a7,f)
a7[f]=a2+d
if(!(o<64))return A.a(a7,o)
a7[o]=a2-d}for(r=0;r<8;++r){s=8+r
q=a7[s]
if(q===0&&a7[16+r]===0&&a7[24+r]===0&&a7[32+r]===0&&a7[40+r]===0&&a7[48+r]===0&&a7[56+r]===0){q=B.a.i(5793*a7[r]+8192,14)
n=(q&2147483647)-((q&2147483648)>>>0)
if(!(r<64))return A.a(a7,r)
a7[r]=n
if(!(s<64))return A.a(a7,s)
a7[s]=n
s=16+r
if(!(s<64))return A.a(a7,s)
a7[s]=n
s=24+r
if(!(s<64))return A.a(a7,s)
a7[s]=n
s=32+r
if(!(s<64))return A.a(a7,s)
a7[s]=n
s=40+r
if(!(s<64))return A.a(a7,s)
a7[s]=n
s=48+r
if(!(s<64))return A.a(a7,s)
a7[s]=n
s=56+r
if(!(s<64))return A.a(a7,s)
a7[s]=n
continue}o=B.a.i(5793*a7[r]+2048,12)
m=(o&2147483647)-((o&2147483648)>>>0)
o=32+r
l=B.a.i(5793*a7[o]+2048,12)
k=(l&2147483647)-((l&2147483648)>>>0)
l=16+r
j=a7[l]
i=48+r
h=a7[i]
g=56+r
f=a7[g]
e=B.a.i(2896*(q-f)+2048,12)
d=(e&2147483647)-((e&2147483648)>>>0)
f=B.a.i(2896*(q+f)+2048,12)
c=(f&2147483647)-((f&2147483648)>>>0)
f=24+r
b=a7[f]
q=40+r
a=a7[q]
e=B.a.i(m-k+1,1)
n=(e&2147483647)-((e&2147483648)>>>0)
e=B.a.i(m+k+1,1)
m=(e&2147483647)-((e&2147483648)>>>0)
e=B.a.i(j*3784+h*1567+2048,12)
e=(e&2147483647)-((e&2147483648)>>>0)
a0=B.a.i(j*1567-h*3784+2048,12)
j=(a0&2147483647)-((a0&2147483648)>>>0)
a0=B.a.i(d-a+1,1)
a0=(a0&2147483647)-((a0&2147483648)>>>0)
a1=B.a.i(d+a+1,1)
d=(a1&2147483647)-((a1&2147483648)>>>0)
a1=B.a.i(c+b+1,1)
a1=(a1&2147483647)-((a1&2147483648)>>>0)
a2=B.a.i(c-b+1,1)
b=(a2&2147483647)-((a2&2147483648)>>>0)
a2=B.a.i(m-e+1,1)
a2=(a2&2147483647)-((a2&2147483648)>>>0)
e=B.a.i(m+e+1,1)
m=(e&2147483647)-((e&2147483648)>>>0)
e=B.a.i(n-j+1,1)
e=(e&2147483647)-((e&2147483648)>>>0)
a3=B.a.i(n+j+1,1)
k=(a3&2147483647)-((a3&2147483648)>>>0)
a3=B.a.i(d*2276+a1*3406+2048,12)
n=(a3&2147483647)-((a3&2147483648)>>>0)
a1=B.a.i(d*3406-a1*2276+2048,12)
d=(a1&2147483647)-((a1&2147483648)>>>0)
a1=B.a.i(b*799+a0*4017+2048,12)
a1=(a1&2147483647)-((a1&2147483648)>>>0)
a0=B.a.i(b*4017-a0*799+2048,12)
b=(a0&2147483647)-((a0&2147483648)>>>0)
if(!(r<64))return A.a(a7,r)
a7[r]=m+n
if(!(g<64))return A.a(a7,g)
a7[g]=m-n
a7[s]=k+a1
a7[i]=k-a1
a7[l]=e+b
a7[q]=e-b
a7[f]=a2+d
a7[o]=a2-d}for(s=$.kt,r=0;r<64;++r){s.toString
q=B.a.i(a7[r]+8,4)
q=384+((q&2147483647)-((q&2147483648)>>>0))
if(!(q>=0&&q<768))return A.a(s,q)
q=s[q]
if(!(r<64))return A.a(a6,r)
a6[r]=q}},
q0(f4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,e0,e1,e2,e3,e4,e5,e6,e7,e8,e9,f0=f4.r.b,f1=f0.a3(274)?A.o(f0.q(0,274)):0,f2=f4.d,f3=f2.e
f3.toString
f2=f2.d
f2.toString
s=f1>=5&&f1<=8
if(s)r=f2
else r=f3
if(s)q=f3
else q=f2
p=A.T(r,q,B.o,null,null)
p.y=new A.bZ(A.J(t.p,t.z))
for(o=A.cQ(f0,f0.r,A.w(f0).c);o.C();){n=o.d
if(n!==274)p.y.b.h(0,n,f0.q(0,n))}m=f2-1
l=f3-1
f0=f4.Q
f2=f0.length
switch(f2){case 1:if(0>=f2)return A.a(f0,0)
k=f0[0]
j=k.e
i=k.f
h=k.r
f0=p.x
f2=f0.length
f3=f1===8
o=f1===7
n=f1===6
g=f1===5
f=f1===4
e=f1===3
d=f1===2
c=p.a
b=j.length
a=0
a0=0
while(!0){a1=f4.d.d
a1.toString
if(!(a0<a1))break
a2=B.a.L(a0,h)
if(!(a2<b))return A.a(j,a2)
a3=j[a2]
a1=m-a0
a4=a1*c
a5=a0*c
a6=0
while(!0){a7=f4.d.e
a7.toString
if(!(a6<a7))break
a8=B.a.L(a6,i)
if(!(a8<a3.length))return A.a(a3,a8)
a9=a3[a8]
b0=(B.c.m(B.a.p(255,0,255))<<24|B.c.m(B.a.p(a9,0,255))<<16|B.c.m(B.a.p(a9,0,255))<<8|B.c.m(B.a.p(a9,0,255)))>>>0
if(d){a7=a5+(l-a6)
if(!(a7>=0&&a7<f2))return A.a(f0,a7)
f0[a7]=b0}else if(e){a7=a4+(l-a6)
if(!(a7>=0&&a7<f2))return A.a(f0,a7)
f0[a7]=b0}else if(f){a7=a4+a6
if(!(a7>=0&&a7<f2))return A.a(f0,a7)
f0[a7]=b0}else if(g){a7=a6*c+a0
if(!(a7>=0&&a7<f2))return A.a(f0,a7)
f0[a7]=b0}else if(n){a7=a6*c+a1
if(!(a7>=0&&a7<f2))return A.a(f0,a7)
f0[a7]=b0}else if(o){a7=(l-a6)*c+a1
if(!(a7>=0&&a7<f2))return A.a(f0,a7)
f0[a7]=b0}else if(f3){a7=(l-a6)*c+a0
if(!(a7>=0&&a7<f2))return A.a(f0,a7)
f0[a7]=b0}else{b1=a+1
if(!(a>=0&&a<f2))return A.a(f0,a)
f0[a]=b0
a=b1}++a6}++a0}break
case 3:if(0>=f2)return A.a(f0,0)
k=f0[0]
if(1>=f2)return A.a(f0,1)
b2=f0[1]
if(2>=f2)return A.a(f0,2)
b3=f0[2]
b4=k.e
b5=b2.e
b6=b3.e
i=k.f
h=k.r
b7=b2.f
b8=b2.r
b9=b3.f
c0=b3.r
f0=p.x
f2=f0.length
f3=f1===8
o=f1===7
n=f1===6
g=f1===5
f=f1===4
e=f1===3
d=f1===2
c=p.a
b=b4.length
a1=b5.length
a4=b6.length
a=0
a0=0
while(!0){a5=f4.d.d
a5.toString
if(!(a0<a5))break
a2=B.a.L(a0,h)
c1=B.a.L(a0,b8)
c2=B.a.L(a0,c0)
if(!(a2<b))return A.a(b4,a2)
a3=b4[a2]
if(!(c1<a1))return A.a(b5,c1)
c3=b5[c1]
if(!(c2<a4))return A.a(b6,c2)
c4=b6[c2]
a5=m-a0
a7=a5*c
c5=a0*c
a6=0
while(!0){c6=f4.d.e
c6.toString
if(!(a6<c6))break
a8=B.a.L(a6,i)
c7=B.a.L(a6,b7)
c8=B.a.L(a6,b9)
if(!(a8<a3.length))return A.a(a3,a8)
a9=a3[a8]<<8>>>0
if(!(c7<c3.length))return A.a(c3,c7)
c9=c3[c7]-128
if(!(c8<c4.length))return A.a(c4,c8)
d0=c4[c8]-128
c6=B.a.i(a9+359*d0+128,8)
c6=(c6&2147483647)-((c6&2147483648)>>>0)
if(c6<0)d1=0
else d1=c6>255?255:c6
c6=B.a.i(a9-88*c9-183*d0+128,8)
c6=(c6&2147483647)-((c6&2147483648)>>>0)
if(c6<0)d2=0
else d2=c6>255?255:c6
c6=B.a.i(a9+454*c9+128,8)
c6=(c6&2147483647)-((c6&2147483648)>>>0)
if(c6<0)d3=0
else d3=c6>255?255:c6
b0=(B.c.m(B.a.p(255,0,255))<<24|B.c.m(B.a.p(d3,0,255))<<16|B.c.m(B.a.p(d2,0,255))<<8|B.c.m(B.a.p(d1,0,255)))>>>0
if(d){c6=c5+(l-a6)
if(!(c6>=0&&c6<f2))return A.a(f0,c6)
f0[c6]=b0}else if(e){c6=a7+(l-a6)
if(!(c6>=0&&c6<f2))return A.a(f0,c6)
f0[c6]=b0}else if(f){c6=a7+a6
if(!(c6>=0&&c6<f2))return A.a(f0,c6)
f0[c6]=b0}else if(g){c6=a6*c+a0
if(!(c6>=0&&c6<f2))return A.a(f0,c6)
f0[c6]=b0}else if(n){c6=a6*c+a5
if(!(c6>=0&&c6<f2))return A.a(f0,c6)
f0[c6]=b0}else if(o){c6=(l-a6)*c+a5
if(!(c6>=0&&c6<f2))return A.a(f0,c6)
f0[c6]=b0}else if(f3){c6=(l-a6)*c+a0
if(!(c6>=0&&c6<f2))return A.a(f0,c6)
f0[c6]=b0}else{b1=a+1
if(!(a>=0&&a<f2))return A.a(f0,a)
f0[a]=b0
a=b1}++a6}++a0}break
case 4:f3=f4.c
if(f3==null)throw A.d(A.f("Unsupported color mode (4 components)"))
d4=f3.d!==0&&!0
if(0>=f2)return A.a(f0,0)
k=f0[0]
if(1>=f2)return A.a(f0,1)
b2=f0[1]
if(2>=f2)return A.a(f0,2)
b3=f0[2]
if(3>=f2)return A.a(f0,3)
d5=f0[3]
b4=k.e
b5=b2.e
b6=b3.e
d6=d5.e
i=k.f
h=k.r
b7=b2.f
b8=b2.r
b9=b3.f
c0=b3.r
d7=d5.f
d8=d5.r
f0=p.x
f2=f0.length
f3=f1===8
o=f1===7
n=f1===6
g=f1===5
f=f1===4
e=f1===3
d=f1===2
c=!d4
b=p.a
a1=b4.length
a4=b5.length
a5=b6.length
a7=d6.length
a=0
a0=0
while(!0){c5=f4.d.d
c5.toString
if(!(a0<c5))break
a2=B.a.L(a0,h)
c1=B.a.L(a0,b8)
c2=B.a.L(a0,c0)
d9=B.a.L(a0,d8)
if(!(a2<a1))return A.a(b4,a2)
a3=b4[a2]
if(!(c1<a4))return A.a(b5,c1)
c3=b5[c1]
if(!(c2<a5))return A.a(b6,c2)
c4=b6[c2]
if(!(d9<a7))return A.a(d6,d9)
e0=d6[d9]
c5=m-a0
c6=c5*b
e1=a0*b
a6=0
while(!0){e2=f4.d.e
e2.toString
if(!(a6<e2))break
a8=B.a.L(a6,i)
c7=B.a.L(a6,b7)
c8=B.a.L(a6,b9)
e3=B.a.L(a6,d7)
if(c){if(!(a8<a3.length))return A.a(a3,a8)
e4=a3[a8]
if(!(c7<c3.length))return A.a(c3,c7)
e5=c3[c7]
if(!(c8<c4.length))return A.a(c4,c8)
e6=c4[c8]
if(!(e3<e0.length))return A.a(e0,e3)
e7=e0[e3]}else{if(!(a8<a3.length))return A.a(a3,a8)
a9=a3[a8]
if(!(c7<c3.length))return A.a(c3,c7)
c9=c3[c7]
if(!(c8<c4.length))return A.a(c4,c8)
d0=c4[c8]
if(!(e3<e0.length))return A.a(e0,e3)
e7=e0[e3]
e2=d0-128
e8=B.c.m(a9+1.402*e2)
if(e8<0)e8=0
else if(e8>255)e8=255
e4=255-e8
e8=c9-128
e2=B.c.m(a9-0.3441363*e8-0.71413636*e2)
if(e2<0)e2=0
else if(e2>255)e2=255
e5=255-e2
e8=B.c.m(a9+1.772*e8)
if(e8<0)e2=0
else e2=e8>255?255:e8
e6=255-e2}e2=B.a.i(e4*e7,8)
e8=B.a.i(e5*e7,8)
e9=B.a.i(e6*e7,8)
b0=(B.c.m(B.a.p(255,0,255))<<24|B.c.m(B.a.p((e9&2147483647)-((e9&2147483648)>>>0),0,255))<<16|B.c.m(B.a.p((e8&2147483647)-((e8&2147483648)>>>0),0,255))<<8|B.c.m(B.a.p((e2&2147483647)-((e2&2147483648)>>>0),0,255)))>>>0
if(d){e2=e1+(l-a6)
if(!(e2>=0&&e2<f2))return A.a(f0,e2)
f0[e2]=b0}else if(e){e2=c6+(l-a6)
if(!(e2>=0&&e2<f2))return A.a(f0,e2)
f0[e2]=b0}else if(f){e2=c6+a6
if(!(e2>=0&&e2<f2))return A.a(f0,e2)
f0[e2]=b0}else if(g){e2=a6*b+a0
if(!(e2>=0&&e2<f2))return A.a(f0,e2)
f0[e2]=b0}else if(n){e2=a6*b+c5
if(!(e2>=0&&e2<f2))return A.a(f0,e2)
f0[e2]=b0}else if(o){e2=(l-a6)*b+c5
if(!(e2>=0&&e2<f2))return A.a(f0,e2)
f0[e2]=b0}else if(f3){e2=(l-a6)*b+a0
if(!(e2>=0&&e2<f2))return A.a(f0,e2)
f0[e2]=b0}else{b1=a+1
if(!(a>=0&&a<f2))return A.a(f0,a)
f0[a]=b0
a=b1}++a6}++a0}break
default:throw A.d(A.f("Unsupported color mode"))}return p},
oM(a,b,c,d,e,f){A.oJ(f,a,b,c,d,e,!0,f)},
oN(a,b,c,d,e,f){A.oK(f,a,b,c,d,e,!0,f)},
oL(a,b,c,d,e,f){A.oI(f,a,b,c,d,e,!0,f)},
cd(a,b,c,d,e){var s,r,q,p
for(s=0;s<d;++s){r=a.a
q=a.d+s
if(!(q>=0&&q<r.length))return A.a(r,q)
q=r[q]
r=b.a
p=b.d+s
if(!(p>=0&&p<r.length))return A.a(r,p)
p=r[p]
J.n(c.a,c.d+s,q+p)}},
oJ(a,b,c,d,e,f,g,h){var s,r,q=null,p=e*d,o=e+f,n=A.l(a,!1,q,p),m=A.l(a,!1,q,p),l=A.j(m,q,0)
if(e===0){s=n.a
r=n.d
if(!(r>=0&&r<s.length))return A.a(s,r)
m.h(0,0,s[r])
A.cd(A.j(n,q,1),l,A.j(m,q,1),b-1,!0)
l.d+=d
n.d+=d
m.d+=d
e=1}for(s=-d,r=b-1;e<o;){A.cd(n,A.j(l,q,s),m,1,!0)
A.cd(A.j(n,q,1),l,A.j(m,q,1),r,!0);++e
l.d+=d
n.d+=d
m.d+=d}},
oK(a,b,c,d,e,f,g,h){var s,r,q=null,p=e*d,o=e+f,n=A.l(a,!1,q,p),m=A.l(h,!1,q,p),l=A.j(m,q,0)
if(e===0){s=n.a
r=n.d
if(!(r>=0&&r<s.length))return A.a(s,r)
m.h(0,0,s[r])
A.cd(A.j(n,q,1),l,A.j(m,q,1),b-1,!0)
n.d+=d
m.d+=d
e=1}else l.d-=d
for(;e<o;){A.cd(n,l,m,b,!0);++e
l.d+=d
n.d+=d
m.d+=d}},
oI(a,b,c,a0,a1,a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i=null,h=a1*a0,g=a1+a2,f=A.l(a,!1,i,h),e=A.l(a4,!1,i,h),d=A.j(e,i,0)
if(a1===0){s=f.a
r=f.d
if(!(r>=0&&r<s.length))return A.a(s,r)
e.h(0,0,s[r])
A.cd(A.j(f,i,1),d,A.j(e,i,1),b-1,!0)
d.d+=a0
f.d+=a0
e.d+=a0
a1=1}for(s=-a0;a1<g;){A.cd(f,A.j(d,i,s),e,1,!0)
for(q=1;q<b;++q){r=d.a
p=d.d
o=p+(q-1)
n=r.length
if(!(o>=0&&o<n))return A.a(r,o)
o=r[o]
m=q-a0
l=p+m
if(!(l>=0&&l<n))return A.a(r,l)
l=r[l]
m=p+(m-1)
if(!(m>=0&&m<n))return A.a(r,m)
k=o+l-r[m]
if((k&4294967040)>>>0===0)j=k
else j=k<0?0:255
r=f.a
p=f.d+q
if(!(p>=0&&p<r.length))return A.a(r,p)
p=r[p]
J.n(e.a,e.d+q,p+j)}++a1
d.d+=a0
f.d+=a0
e.d+=a0}},
nx(a){var s,r,q,p
if($.O==null)A.aP()
$.kE()[0]=a
s=$.mV()
if(0>=s.length)return A.a(s,0)
r=s[0]
if(a===0)return r>>>16
q=r>>>23&511
s=$.h8.bA()
if(!(q<s.length))return A.a(s,q)
q=s[q]
if(q!==0){p=r&8388607
return q+(p+4095+(p>>>13&1)>>>13)}return A.ny(r)},
ny(a){var s,r,q=a>>>16&32768,p=(a>>>23&255)-112,o=a&8388607
if(p<=0){if(p<-10)return q
o|=8388608
s=14-p
return(q|B.a.a8(o+(B.a.D(1,s-1)-1)+(B.a.a5(o,s)&1),s))>>>0}else if(p===143)if(o===0)return q|31744
else{o=o>>>13
r=o===0?1:0
return q|o|r|31744}else{o=o+4095+(o>>>13&1)
if((o&8388608)!==0){++p
o=0}if(p>30)return q|31744
return(q|p<<10|o>>>13)>>>0}},
aP(){var s,r,q,p,o
if($.jU!=null)return
s=new Uint32Array(65536)
$.jU=s
$.O=A.nL(s.buffer,0,null)
s=new Uint16Array(512)
$.h8.b=s
for(r=0;r<256;++r){q=(r&255)-112
if(q<=0||q>=30){$.h8.toString
s[r]=0
p=(r|256)>>>0
if(!(p<512))return A.a(s,p)
s[p]=0}else{$.h8.toString
p=q<<10>>>0
s[r]=p
o=(r|256)>>>0
if(!(o<512))return A.a(s,o)
s[o]=(p|32768)>>>0}}for(s=$.jU,r=0;r<65536;++r){s.toString
s[r]=A.nz(r)}},
nz(a){var s,r=a>>>15&1,q=a>>>10&31,p=a&1023
if(q===0)if(p===0)return r<<31>>>0
else{for(;(p&1024)===0;){p=p<<1;--q}++q
p&=4294966271}else if(q===31){s=r<<31
if(p===0)return(s|2139095040)>>>0
else return(s|p<<13|2139095040)>>>0}return(r<<31|q+112<<23|p<<13)>>>0},
qn(a){$.kG().h(0,0,a)
return $.mX().q(0,0)},
jz(a){var s,r
if(a==null)return"null"
for(s=32,r="";s>-1;--s)r+=(a&B.a.D(1,s))>>>0===0?"0":"1"
return r.charCodeAt(0)==0?r:r},
pU(a){var s,r,q=A.jV(a)
if(!a.y.b.a3(274)||A.o(a.y.b.q(0,274))===1)return q
q.y=new A.bZ(A.J(t.p,t.z))
for(s=a.y.b,s=A.cQ(s,s.r,A.w(s).c);s.C();){r=s.d
if(r!==274)q.y.b.h(0,r,a.y.b.q(0,r))}switch(A.o(a.y.b.q(0,274))){case 2:return A.dN(q)
case 3:switch(2){case 2:A.mr(q)
A.dN(q)
break}return q
case 4:return A.dN(A.fF(q,180))
case 5:return A.dN(A.fF(q,90))
case 6:return A.fF(q,90)
case 7:return A.dN(A.fF(q,-90))
case 8:return A.fF(q,-90)}return q},
pX(a,b,c,d,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=a.a
b=B.c.m(B.a.p(b,0,e-1))
s=a.b
c=B.c.m(B.a.p(c,0,s-1))
if(b+d>e)d=e-b
if(c+a0>s)a0=s-c
r=A.T(d,a0,a.c,a.y,a.z)
for(s=a.x,q=s.length,p=r.x,o=r.a,n=p.length,m=c,l=0;l<a0;++l,++m)for(k=m*e,j=l*o,i=b,h=0;h<d;++h,++i){g=k+i
if(!(g>=0&&g<q))return A.a(s,g)
g=s[g]
f=j+h
if(!(f>=0&&f<n))return A.a(p,f)
p[f]=g}return r},
pY(a,b,c){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d
a=A.pU(a)
if(b<=0)b=B.c.m(c*(a.b/a.a))
if(c<=0)c=B.c.m(b*(a.a/a.b))
s=a.a
if(c===s&&b===a.b)return A.jV(a)
r=A.T(c,b,a.c,a.y,a.z)
q=a.b/b
p=s/c
o=new Int32Array(c)
for(n=0;n<c;++n){m=B.c.m(n*p)
if(!(n<c))return A.a(o,n)
o[n]=m}for(m=a.x,l=m.length,k=r.x,j=r.a,i=k.length,h=0;h<b;++h)for(g=B.c.m(h*q)*s,f=h*j,n=0;n<c;++n){if(!(n<c))return A.a(o,n)
e=g+o[n]
if(!(e>=0&&e<l))return A.a(m,e)
e=m[e]
d=f+n
if(!(d>=0&&d<i))return A.a(k,d)
k[d]=e}return r},
fF(a6,a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5=B.a.I(a7,360)
if(B.a.I(a5,90)===0){s=a6.a
r=s-1
q=a6.b
p=q-1
switch(B.a.F(a5,90)){case 1:o=A.T(q,s,a6.c,a6.y,a6.z)
for(q=o.b,n=o.a,m=a6.x,l=m.length,k=o.x,j=k.length,i=0;i<q;++i)for(h=i*n,g=0;g<n;++g){f=(p-g)*s+i
if(!(f>=0&&f<l))return A.a(m,f)
f=m[f]
e=h+g
if(!(e>=0&&e<j))return A.a(k,e)
k[e]=f}return o
case 2:o=A.T(s,q,a6.c,a6.y,a6.z)
for(q=o.b,n=o.a,m=a6.x,l=m.length,k=o.x,j=k.length,i=0;i<q;++i)for(h=(p-i)*s,f=i*n,g=0;g<n;++g){e=h+(r-g)
if(!(e>=0&&e<l))return A.a(m,e)
e=m[e]
d=f+g
if(!(d>=0&&d<j))return A.a(k,d)
k[d]=e}return o
case 3:o=A.T(q,s,a6.c,a6.y,a6.z)
for(q=o.b,n=o.a,m=a6.x,l=m.length,k=o.x,j=k.length,i=0;i<q;++i)for(h=r-i,f=i*n,g=0;g<n;++g){e=g*s+h
if(!(e>=0&&e<l))return A.a(m,e)
e=m[e]
d=f+g
if(!(d>=0&&d<j))return A.a(k,d)
k[d]=e}return o
default:return A.jV(a6)}}c=a5*3.141592653589793/180
b=Math.cos(c)
a=Math.sin(c)
s=a6.a
q=a6.b
a0=0.5*s
a1=0.5*q
n=Math.abs(s*b)+Math.abs(q*a)
a2=0.5*n
q=Math.abs(s*a)+Math.abs(q*b)
a3=0.5*q
o=A.T(B.c.m(n),B.c.m(q),B.f,a6.y,a6.z)
for(s=o.b,q=o.a,n=o.x,m=n.length,i=0;i<s;++i)for(l=i-a3,k=l*a,l*=b,j=i*q,g=0;g<q;++g){h=g-a2
a4=a6.f6(a0+h*b+k,a1-h*a+l,B.b1)
h=j+g
if(!(h>=0&&h<m))return A.a(n,h)
n[h]=a4}return o},
mr(a){var s,r,q,p,o,n,m,l,k,j,i=a.a,h=a.b,g=B.a.F(h,2)
for(s=a.x,r=s.length,q=h-1,p=0;p<g;++p){o=p*i
n=(q-p)*i
for(m=0;m<i;++m){l=n+m
if(!(l>=0&&l<r))return A.a(s,l)
k=s[l]
j=o+m
if(!(j>=0&&j<r))return A.a(s,j)
s[l]=s[j]
s[j]=k}}return a},
dN(a){var s,r,q,p,o,n,m,l,k,j=a.a,i=a.b,h=B.a.F(j,2)
for(s=j-1,r=a.x,q=r.length,p=0;p<i;++p){o=p*j
for(n=0;n<h;++n){m=o+(s-n)
if(!(m>=0&&m<q))return A.a(r,m)
l=r[m]
k=o+n
if(!(k>=0&&k<q))return A.a(r,k)
r[m]=r[k]
r[k]=l}}return a},
my(a){var s,r,q,p,o
try{if(a!=null)a.$0()}catch(r){s=A.a0(r)
q=A.v(a)
p=A.v(s)
o=$.ac
if(o!=null){o=o.c
if(o!=null)o.c8(900,"callback "+q+" failed: "+p)}}}},J={
kA(a,b,c,d){return{i:a,p:b,e:c,x:d}},
jC(a){var s,r,q,p,o,n=a[v.dispatchPropertyName]
if(n==null)if($.kz==null){A.q9()
n=a[v.dispatchPropertyName]}if(n!=null){s=n.p
if(!1===s)return n.i
if(!0===s)return a
r=Object.getPrototypeOf(a)
if(s===r)return n.i
if(n.e===r)throw A.d(A.da("Return interceptor for "+A.v(s(a,n))))}q=a.constructor
if(q==null)p=null
else{o=$.j5
if(o==null)o=$.j5=v.getIsolateTag("_$dart_js")
p=q[o]}if(p!=null)return p
p=A.qe(a)
if(p!=null)return p
if(typeof a=="function")return B.b4
s=Object.getPrototypeOf(a)
if(s==null)return B.aM
if(s===Object.prototype)return B.aM
if(typeof q=="function"){o=$.j5
if(o==null)o=$.j5=v.getIsolateTag("_$dart_js")
Object.defineProperty(q,o,{value:B.a_,enumerable:false,writable:true,configurable:true})
return B.a_}return B.a_},
jY(a,b){if(a<0||a>4294967295)throw A.d(A.Q(a,0,4294967295,"length",null))
return J.l8(new Array(a),b)},
ah(a,b){if(a<0||a>4294967295)throw A.d(A.Q(a,0,4294967295,"length",null))
return J.l8(new Array(a),b)},
eq(a,b){if(a<0)throw A.d(A.bu("Length must be a non-negative integer: "+a,null))
return A.b(new Array(a),b.l("p<0>"))},
nC(a,b){if(a<0)throw A.d(A.bu("Length must be a non-negative integer: "+a,null))
return A.b(new Array(a),b.l("p<0>"))},
l8(a,b){return J.l9(A.b(a,b.l("p<0>")),b)},
l9(a,b){a.fixed$length=Array
return a},
lb(a){if(a<256)switch(a){case 9:case 10:case 11:case 12:case 13:case 32:case 133:case 160:return!0
default:return!1}switch(a){case 5760:case 8192:case 8193:case 8194:case 8195:case 8196:case 8197:case 8198:case 8199:case 8200:case 8201:case 8202:case 8232:case 8233:case 8239:case 8287:case 12288:case 65279:return!0
default:return!1}},
nD(a,b){var s,r
for(s=a.length;b<s;){r=B.d.W(a,b)
if(r!==32&&r!==13&&!J.lb(r))break;++b}return b},
nE(a,b){var s,r
for(;b>0;b=s){s=b-1
r=B.d.aX(a,s)
if(r!==32&&r!==13&&!J.lb(r))break}return b},
cn(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.cN.prototype
return J.es.prototype}if(typeof a=="string")return J.c6.prototype
if(a==null)return J.cO.prototype
if(typeof a=="boolean")return J.er.prototype
if(a.constructor==Array)return J.p.prototype
if(typeof a!="object"){if(typeof a=="function")return J.aQ.prototype
return a}if(a instanceof A.t)return a
return J.jC(a)},
ae(a){if(typeof a=="string")return J.c6.prototype
if(a==null)return a
if(a.constructor==Array)return J.p.prototype
if(typeof a!="object"){if(typeof a=="function")return J.aQ.prototype
return a}if(a instanceof A.t)return a
return J.jC(a)},
R(a){if(a==null)return a
if(a.constructor==Array)return J.p.prototype
if(typeof a!="object"){if(typeof a=="function")return J.aQ.prototype
return a}if(a instanceof A.t)return a
return J.jC(a)},
q1(a){if(typeof a=="number")return J.c5.prototype
if(a==null)return a
if(!(a instanceof A.t))return J.bI.prototype
return a},
ky(a){if(a==null)return a
if(typeof a!="object"){if(typeof a=="function")return J.aQ.prototype
return a}if(a instanceof A.t)return a
return J.jC(a)},
q2(a){if(a==null)return a
if(!(a instanceof A.t))return J.bI.prototype
return a},
au(a,b){if(a==null)return b==null
if(typeof a!="object")return b!=null&&a===b
return J.cn(a).br(a,b)},
kI(a,b){if(typeof b==="number")if(a.constructor==Array||typeof a=="string"||A.qc(a,a[v.dispatchPropertyName]))if(b>>>0===b&&b<a.length)return a[b]
return J.ae(a).q(a,b)},
n(a,b,c){return J.R(a).h(a,b,c)},
mZ(a,b,c,d){return J.ky(a).j9(a,b,c,d)},
n_(a,b,c,d){return J.ky(a).d_(a,b,c,d)},
kJ(a,b){return J.R(a).ar(a,b)},
kK(a,b){return J.q2(a).jR(a,b)},
n0(a,b){return J.R(a).b8(a,b)},
aJ(a,b,c,d){return J.R(a).ak(a,b,c,d)},
dP(a){return J.R(a).gaC(a)},
dQ(a){return J.cn(a).gaf(a)},
aK(a){return J.R(a).gZ(a)},
b5(a){return J.ae(a).gv(a)},
n1(a,b,c){return J.R(a).ba(a,b,c)},
kL(a,b,c){return J.ky(a).f9(a,b,c)},
kM(a,b){return J.R(a).di(a,b)},
fI(a,b,c){return J.R(a).a9(a,b,c)},
n2(a){return J.R(a).aP(a)},
n3(a,b){return J.q1(a).bo(a,b)},
bR(a){return J.cn(a).u(a)},
n4(a,b){return J.R(a).bb(a,b)},
eg:function eg(){},
er:function er(){},
cO:function cO(){},
ay:function ay(){},
bb:function bb(){},
eN:function eN(){},
bI:function bI(){},
aQ:function aQ(){},
p:function p(a){this.$ti=a},
hp:function hp(a){this.$ti=a},
bv:function bv(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
c5:function c5(){},
cN:function cN(){},
es:function es(){},
c6:function c6(){}},B={}
var w=[A,J,B]
var $={}
A.jZ.prototype={}
J.eg.prototype={
br(a,b){return a===b},
gaf(a){return A.d_(a)},
u(a){return"Instance of '"+A.hP(a)+"'"}}
J.er.prototype={
u(a){return String(a)},
gaf(a){return a?519018:218159},
$iG:1}
J.cO.prototype={
br(a,b){return null==b},
u(a){return"null"},
gaf(a){return 0},
$iK:1}
J.ay.prototype={}
J.bb.prototype={
gaf(a){return 0},
u(a){return String(a)},
$ila:1}
J.eN.prototype={}
J.bI.prototype={}
J.aQ.prototype={
u(a){var s=a[$.mC()]
if(s==null)return this.fq(a)
return"JavaScript function for "+J.bR(s)},
$ibA:1}
J.p.prototype={
A(a,b){A.a5(a).c.a(b)
if(!!a.fixed$length)A.F(A.Z("add"))
a.push(b)},
bP(a,b){var s
if(!!a.fixed$length)A.F(A.Z("remove"))
for(s=0;s<a.length;++s)if(J.au(a[s],b)){a.splice(s,1)
return!0}return!1},
bb(a,b){var s=A.a5(a)
return new A.W(a,s.l("G(1)").a(b),s.l("W<1>"))},
bE(a,b){var s
A.a5(a).l("k<1>").a(b)
if(!!a.fixed$length)A.F(A.Z("addAll"))
for(s=new A.bo(b.a(),b.$ti.l("bo<1>"));s.C();)a.push(s.gH())},
ba(a,b,c){var s=A.a5(a)
return new A.aS(a,s.G(c).l("1(2)").a(b),s.l("@<1>").G(c).l("aS<1,2>"))},
di(a,b){return A.kd(a,b,null,A.a5(a).c)},
ar(a,b){if(!(b>=0&&b<a.length))return A.a(a,b)
return a[b]},
a9(a,b,c){if(b<0||b>a.length)throw A.d(A.Q(b,0,a.length,"start",null))
if(c<b||c>a.length)throw A.d(A.Q(c,b,a.length,"end",null))
if(b===c)return A.b([],A.a5(a))
return A.b(a.slice(b,c),A.a5(a))},
gaC(a){if(a.length>0)return a[0]
throw A.d(A.bC())},
gk0(a){var s=a.length
if(s>0)return a[s-1]
throw A.d(A.bC())},
U(a,b,c,d,e){var s,r,q,p,o
A.a5(a).l("k<1>").a(d)
if(!!a.immutable$list)A.F(A.Z("setRange"))
A.ab(b,c,a.length)
s=c-b
if(s===0)return
A.eX(e,"skipCount")
if(t.j.b(d)){r=d
q=e}else{r=J.kM(d,e).a7(0,!1)
q=0}p=J.ae(r)
if(q+s>p.gv(r))throw A.d(A.l6())
if(q<b)for(o=s-1;o>=0;--o)a[b+o]=p.q(r,q+o)
else for(o=0;o<s;++o)a[b+o]=p.q(r,q+o)},
ak(a,b,c,d){var s
A.a5(a).l("1?").a(d)
if(!!a.immutable$list)A.F(A.Z("fill range"))
A.ab(b,c,a.length)
for(s=b;s<c;++s)a[s]=d},
b8(a,b){var s,r
A.a5(a).l("G(1)").a(b)
s=a.length
for(r=0;r<s;++r){if(!A.b0(b.$1(a[r])))return!1
if(a.length!==s)throw A.d(A.ba(a))}return!0},
aB(a,b){var s
for(s=0;s<a.length;++s)if(J.au(a[s],b))return!0
return!1},
gal(a){return a.length===0},
geN(a){return a.length!==0},
u(a){return A.jX(a,"[","]")},
a7(a,b){var s=A.b(a.slice(0),A.a5(a))
return s},
aP(a){return this.a7(a,!0)},
gZ(a){return new J.bv(a,a.length,A.a5(a).l("bv<1>"))},
gaf(a){return A.d_(a)},
gv(a){return a.length},
sv(a,b){if(!!a.fixed$length)A.F(A.Z("set length"))
if(b<0)throw A.d(A.Q(b,0,null,"newLength",null))
if(b>a.length)A.a5(a).c.a(null)
a.length=b},
q(a,b){if(!(b>=0&&b<a.length))throw A.d(A.cm(a,b))
return a[b]},
h(a,b,c){A.o(b)
A.a5(a).c.a(c)
if(!!a.immutable$list)A.F(A.Z("indexed set"))
if(!(b>=0&&b<a.length))throw A.d(A.cm(a,b))
a[b]=c},
$ir:1,
$ik:1,
$ih:1}
J.hp.prototype={}
J.bv.prototype={
gH(){var s=this.d
return s==null?this.$ti.c.a(s):s},
C(){var s,r=this,q=r.a,p=q.length
if(r.b!==p)throw A.d(A.b3(q))
s=r.c
if(s>=p){r.sdH(null)
return!1}r.sdH(q[s]);++r.c
return!0},
sdH(a){this.d=this.$ti.l("1?").a(a)},
$iI:1}
J.c5.prototype={
d2(a,b){var s
if(a<b)return-1
else if(a>b)return 1
else if(a===b){if(a===0){s=B.a.gbL(b)
if(this.gbL(a)===s)return 0
if(this.gbL(a))return-1
return 1}return 0}else if(isNaN(a)){if(isNaN(b))return 0
return 1}else return-1},
gbL(a){return a===0?1/a<0:a<0},
m(a){var s
if(a>=-2147483648&&a<=2147483647)return a|0
if(isFinite(a)){s=a<0?Math.ceil(a):Math.floor(a)
return s+0}throw A.d(A.Z(""+a+".toInt()"))},
bk(a){var s,r
if(a>=0){if(a<=2147483647){s=a|0
return a===s?s:s+1}}else if(a>=-2147483648)return a|0
r=Math.ceil(a)
if(isFinite(r))return r
throw A.d(A.Z(""+a+".ceil()"))},
cn(a){var s,r
if(a>=0){if(a<=2147483647)return a|0}else if(a>=-2147483648){s=a|0
return a===s?s:s-1}r=Math.floor(a)
if(isFinite(r))return r
throw A.d(A.Z(""+a+".floor()"))},
aE(a){if(a>0){if(a!==1/0)return Math.round(a)}else if(a>-1/0)return 0-Math.round(0-a)
throw A.d(A.Z(""+a+".round()"))},
p(a,b,c){if(B.a.d2(b,c)>0)throw A.d(A.br(b))
if(this.d2(a,b)<0)return b
if(this.d2(a,c)>0)return c
return a},
bo(a,b){var s,r,q,p
if(b<2||b>36)throw A.d(A.Q(b,2,36,"radix",null))
s=a.toString(b)
if(B.d.aX(s,s.length-1)!==41)return s
r=/^([\da-z]+)(?:\.([\da-z]+))?\(e\+(\d+)\)$/.exec(s)
if(r==null)A.F(A.Z("Unexpected toString result: "+s))
q=r.length
if(1>=q)return A.a(r,1)
s=r[1]
if(3>=q)return A.a(r,3)
p=+r[3]
q=r[2]
if(q!=null){s+=q
p-=q.length}return s+B.d.ap("0",p)},
u(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
gaf(a){var s,r,q,p,o=a|0
if(a===o)return o&536870911
s=Math.abs(a)
r=Math.log(s)/0.6931471805599453|0
q=Math.pow(2,r)
p=s<1?s/q:q/s
return((p*9007199254740992|0)+(p*3542243181176521|0))*599197+r*1259&536870911},
I(a,b){var s=a%b
if(s===0)return 0
if(s>0)return s
if(b<0)return s-b
else return s+b},
V(a,b){A.ph(b)
if((a|0)===a)if(b>=1||b<-1)return a/b|0
return this.em(a,b)},
F(a,b){return(a|0)===a?a/b|0:this.em(a,b)},
em(a,b){var s=a/b
if(s>=-2147483648&&s<=2147483647)return s|0
if(s>0){if(s!==1/0)return Math.floor(s)}else if(s>-1/0)return Math.ceil(s)
throw A.d(A.Z("Result of truncating division is "+A.v(s)+": "+A.v(a)+" ~/ "+b))},
D(a,b){if(b<0)throw A.d(A.br(b))
return b>31?0:a<<b>>>0},
B(a,b){return b>31?0:a<<b>>>0},
a8(a,b){var s
if(b<0)throw A.d(A.br(b))
if(a>0)s=this.L(a,b)
else{s=b>31?31:b
s=a>>s>>>0}return s},
i(a,b){var s
if(a>0)s=this.L(a,b)
else{s=b>31?31:b
s=a>>s>>>0}return s},
a5(a,b){if(0>b)throw A.d(A.br(b))
return this.L(a,b)},
L(a,b){return b>31?0:a>>>b},
$iy:1,
$iE:1}
J.cN.prototype={
X(a,b){var s=this.D(1,b-1)
return((a&s-1)>>>0)-((a&s)>>>0)},
$ie:1}
J.es.prototype={}
J.c6.prototype={
aX(a,b){if(b<0)throw A.d(A.cm(a,b))
if(b>=a.length)A.F(A.cm(a,b))
return a.charCodeAt(b)},
W(a,b){if(b>=a.length)throw A.d(A.cm(a,b))
return a.charCodeAt(b)},
bq(a,b){return a+b},
aT(a,b,c){return a.substring(b,A.ab(b,c,a.length))},
dk(a,b){return this.aT(a,b,null)},
kE(a){var s,r,q,p=a.trim(),o=p.length
if(o===0)return p
if(this.W(p,0)===133){s=J.nD(p,1)
if(s===o)return""}else s=0
r=o-1
q=this.aX(p,r)===133?J.nE(p,r):o
if(s===0&&q===o)return p
return p.substring(s,q)},
ap(a,b){var s,r
if(0>=b)return""
if(b===1||a.length===0)return a
if(b!==b>>>0)throw A.d(B.aW)
for(s=a,r="";!0;){if((b&1)===1)r=s+r
b=b>>>1
if(b===0)break
s+=s}return r},
k5(a,b){var s=a.length,r=b.length
if(s+r>s)s-=r
return a.lastIndexOf(b,s)},
u(a){return a},
gaf(a){var s,r,q
for(s=a.length,r=0,q=0;q<s;++q){r=r+a.charCodeAt(q)&536870911
r=r+((r&524287)<<10)&536870911
r^=r>>6}r=r+((r&67108863)<<3)&536870911
r^=r>>11
return r+((r&16383)<<15)&536870911},
gv(a){return a.length},
$ihL:1,
$im:1}
A.bD.prototype={
u(a){return"LateInitializationError: "+this.a}}
A.a8.prototype={
gv(a){return this.a.length},
q(a,b){return B.d.aX(this.a,b)}}
A.jL.prototype={
$0(){var s=new A.L($.C,t.av)
s.cu(null)
return s},
$S:30}
A.r.prototype={}
A.X.prototype={
gZ(a){var s=this
return new A.bF(s,s.gv(s),A.w(s).l("bF<X.E>"))},
gal(a){return this.gv(this)===0},
gaC(a){if(this.gv(this)===0)throw A.d(A.bC())
return this.ar(0,0)},
b8(a,b){var s,r,q=this
A.w(q).l("G(X.E)").a(b)
s=q.gv(q)
for(r=0;r<s;++r){if(!A.b0(b.$1(q.ar(0,r))))return!1
if(s!==q.gv(q))throw A.d(A.ba(q))}return!0},
bb(a,b){return this.fl(0,A.w(this).l("G(X.E)").a(b))},
ba(a,b,c){var s=A.w(this)
return new A.aS(this,s.G(c).l("1(X.E)").a(b),s.l("@<X.E>").G(c).l("aS<1,2>"))},
a7(a,b){return A.hA(this,!0,A.w(this).l("X.E"))},
aP(a){return this.a7(a,!0)}}
A.d7.prototype={
ghM(){var s=J.b5(this.a),r=this.c
if(r==null||r>s)return s
return r},
gjg(){var s=J.b5(this.a),r=this.b
if(r>s)return s
return r},
gv(a){var s,r=J.b5(this.a),q=this.b
if(q>=r)return 0
s=this.c
if(s==null||s>=r)return r-q
if(typeof s!=="number")return s.ac()
return s-q},
ar(a,b){var s=this,r=s.gjg()+b
if(b<0||r>=s.ghM())throw A.d(A.hn(b,s,"index",null,null))
return J.kJ(s.a,r)},
a7(a,b){var s,r,q,p=this,o=p.b,n=p.a,m=J.ae(n),l=m.gv(n),k=p.c
if(k!=null&&k<l)l=k
s=l-o
if(s<=0){n=p.$ti.c
return b?J.eq(0,n):J.jY(0,n)}r=A.H(s,m.ar(n,o),b,p.$ti.c)
for(q=1;q<s;++q){B.b.h(r,q,m.ar(n,o+q))
if(m.gv(n)<l)throw A.d(A.ba(p))}return r},
aP(a){return this.a7(a,!0)}}
A.bF.prototype={
gH(){var s=this.d
return s==null?this.$ti.c.a(s):s},
C(){var s,r=this,q=r.a,p=J.ae(q),o=p.gv(q)
if(r.b!==o)throw A.d(A.ba(q))
s=r.c
if(s>=o){r.saU(null)
return!1}r.saU(p.ar(q,s));++r.c
return!0},
saU(a){this.d=this.$ti.l("1?").a(a)},
$iI:1}
A.aR.prototype={
gZ(a){var s=A.w(this)
return new A.cU(J.aK(this.a),this.b,s.l("@<1>").G(s.z[1]).l("cU<1,2>"))},
gv(a){return J.b5(this.a)},
gaC(a){return this.b.$1(J.dP(this.a))}}
A.by.prototype={$ir:1}
A.cU.prototype={
C(){var s=this,r=s.b
if(r.C()){s.saU(s.c.$1(r.gH()))
return!0}s.saU(null)
return!1},
gH(){var s=this.a
return s==null?this.$ti.z[1].a(s):s},
saU(a){this.a=this.$ti.l("2?").a(a)}}
A.aS.prototype={
gv(a){return J.b5(this.a)},
ar(a,b){return this.b.$1(J.kJ(this.a,b))}}
A.W.prototype={
gZ(a){return new A.dk(J.aK(this.a),this.b,this.$ti.l("dk<1>"))},
ba(a,b,c){var s=this.$ti
return new A.aR(this,s.G(c).l("1(2)").a(b),s.l("@<1>").G(c).l("aR<1,2>"))}}
A.dk.prototype={
C(){var s,r
for(s=this.a,r=this.b;s.C();)if(A.b0(r.$1(s.gH())))return!0
return!1},
gH(){return this.a.gH()}}
A.cx.prototype={
gZ(a){var s=this.$ti
return new A.cy(J.aK(this.a),this.b,B.a0,s.l("@<1>").G(s.z[1]).l("cy<1,2>"))}}
A.cy.prototype={
gH(){var s=this.d
return s==null?this.$ti.z[1].a(s):s},
C(){var s,r,q=this
if(q.c==null)return!1
for(s=q.a,r=q.b;!q.c.C();){q.saU(null)
if(s.C()){q.sdI(null)
q.sdI(J.aK(r.$1(s.gH())))}else return!1}q.saU(q.c.gH())
return!0},
sdI(a){this.c=this.$ti.l("I<2>?").a(a)},
saU(a){this.d=this.$ti.l("2?").a(a)},
$iI:1}
A.bz.prototype={
gZ(a){return B.a0},
gv(a){return 0},
gaC(a){throw A.d(A.bC())},
bb(a,b){this.$ti.l("G(1)").a(b)
return this},
ba(a,b,c){this.$ti.G(c).l("1(2)").a(b)
return new A.bz(c.l("bz<0>"))},
a7(a,b){var s=J.eq(0,this.$ti.c)
return s},
aP(a){return this.a7(a,!0)}}
A.cu.prototype={
C(){return!1},
gH(){throw A.d(A.bC())},
$iI:1}
A.a2.prototype={}
A.bk.prototype={
h(a,b,c){A.o(b)
A.w(this).l("bk.E").a(c)
throw A.d(A.Z("Cannot modify an unmodifiable list"))},
U(a,b,c,d,e){A.w(this).l("k<bk.E>").a(d)
throw A.d(A.Z("Cannot modify an unmodifiable list"))},
az(a,b,c,d){return this.U(a,b,c,d,0)}}
A.cc.prototype={}
A.bX.prototype={
gal(a){return this.gv(this)===0},
u(a){return A.k2(this)},
$iaa:1}
A.ct.prototype={
gv(a){return this.a},
a3(a){if(typeof a!="string")return!1
if("__proto__"===a)return!1
return this.b.hasOwnProperty(a)},
q(a,b){if(!this.a3(b))return null
return this.b[A.a_(b)]},
av(a,b){var s,r,q,p,o,n=this.$ti
n.l("~(1,2)").a(b)
s=this.c
for(r=s.length,q=this.b,n=n.z[1],p=0;p<r;++p){o=A.a_(s[p])
b.$2(o,n.a(q[o]))}},
gaN(){return new A.dl(this,this.$ti.l("dl<1>"))},
gaG(){var s=this.$ti
return A.k3(this.c,new A.fW(this),s.c,s.z[1])}}
A.fW.prototype={
$1(a){var s=this.a,r=s.$ti
return r.z[1].a(s.b[A.a_(r.c.a(a))])},
$S(){return this.a.$ti.l("2(1)")}}
A.dl.prototype={
gZ(a){var s=this.a.c
return new J.bv(s,s.length,A.a5(s).l("bv<1>"))},
gv(a){return this.a.c.length}}
A.cC.prototype={
bg(){var s,r,q,p=this,o=p.$map
if(o==null){s=p.$ti
r=s.c
q=A.nu(r)
o=A.le(A.pE(),q,r,s.z[1])
A.mq(p.a,o)
p.$map=o}return o},
a3(a){return this.bg().a3(a)},
q(a,b){return this.bg().q(0,b)},
av(a,b){this.$ti.l("~(1,2)").a(b)
this.bg().av(0,b)},
gaN(){var s=this.bg()
return new A.aA(s,A.w(s).l("aA<1>"))},
gaG(){return this.bg().gaG()},
gv(a){return this.bg().a}}
A.h5.prototype={
$1(a){return this.a.b(a)},
$S:47}
A.i6.prototype={
aD(a){var s,r,q=this,p=new RegExp(q.a).exec(a)
if(p==null)return null
s=Object.create(null)
r=q.b
if(r!==-1)s.arguments=p[r+1]
r=q.c
if(r!==-1)s.argumentsExpr=p[r+1]
r=q.d
if(r!==-1)s.expr=p[r+1]
r=q.e
if(r!==-1)s.method=p[r+1]
r=q.f
if(r!==-1)s.receiver=p[r+1]
return s}}
A.cY.prototype={
u(a){var s=this.b
if(s==null)return"NoSuchMethodError: "+this.a
return"NoSuchMethodError: method not found: '"+s+"' on null"}}
A.ew.prototype={
u(a){var s,r=this,q="NoSuchMethodError: method not found: '",p=r.b
if(p==null)return"NoSuchMethodError: "+r.a
s=r.c
if(s==null)return q+p+"' ("+r.a+")"
return q+p+"' on '"+s+"' ("+r.a+")"}}
A.f9.prototype={
u(a){var s=this.a
return s.length===0?"Error":"Error: "+s}}
A.hH.prototype={
u(a){return"Throw of null ('"+(this.a===null?"null":"undefined")+"' from JavaScript)"}}
A.cw.prototype={}
A.dA.prototype={
u(a){var s,r=this.b
if(r!=null)return r
r=this.a
s=r!==null&&typeof r==="object"?r.stack:null
return this.b=s==null?"":s},
$ibg:1}
A.b9.prototype={
u(a){var s=this.constructor,r=s==null?null:s.name
return"Closure '"+A.mA(r==null?"unknown":r)+"'"},
$ibA:1,
gkK(){return this},
$C:"$1",
$R:1,
$D:null}
A.dV.prototype={$C:"$0",$R:0}
A.dW.prototype={$C:"$2",$R:2}
A.f4.prototype={}
A.eZ.prototype={
u(a){var s=this.$static_name
if(s==null)return"Closure of unknown static method"
return"Closure '"+A.mA(s)+"'"}}
A.bU.prototype={
br(a,b){if(b==null)return!1
if(this===b)return!0
if(!(b instanceof A.bU))return!1
return this.$_target===b.$_target&&this.a===b.a},
gaf(a){return(A.mu(this.a)^A.d_(this.$_target))>>>0},
u(a){return"Closure '"+this.$_name+"' of "+("Instance of '"+A.hP(this.a)+"'")}}
A.eY.prototype={
u(a){return"RuntimeError: "+this.a}}
A.fi.prototype={
u(a){return"Assertion failed: "+A.cv(this.a)}}
A.ap.prototype={
gv(a){return this.a},
gal(a){return this.a===0},
gaN(){return new A.aA(this,A.w(this).l("aA<1>"))},
gaG(){var s=A.w(this)
return A.k3(new A.aA(this,s.l("aA<1>")),new A.hw(this),s.c,s.z[1])},
a3(a){var s,r
if(typeof a=="string"){s=this.b
if(s==null)return!1
return s[a]!=null}else if(typeof a=="number"&&(a&0x3fffffff)===a){r=this.c
if(r==null)return!1
return r[a]!=null}else return this.eJ(a)},
eJ(a){var s=this.d
if(s==null)return!1
return this.bJ(s[this.bI(a)],a)>=0},
bE(a,b){A.w(this).l("aa<1,2>").a(b).av(0,new A.hv(this))},
q(a,b){var s,r,q,p,o=null
if(typeof b=="string"){s=this.b
if(s==null)return o
r=s[b]
q=r==null?o:r.b
return q}else if(typeof b=="number"&&(b&0x3fffffff)===b){p=this.c
if(p==null)return o
r=p[b]
q=r==null?o:r.b
return q}else return this.eK(b)},
eK(a){var s,r,q=this.d
if(q==null)return null
s=q[this.bI(a)]
r=this.bJ(s,a)
if(r<0)return null
return s[r].b},
h(a,b,c){var s,r,q=this,p=A.w(q)
p.c.a(b)
p.z[1].a(c)
if(typeof b=="string"){s=q.b
q.dq(s==null?q.b=q.cR():s,b,c)}else if(typeof b=="number"&&(b&0x3fffffff)===b){r=q.c
q.dq(r==null?q.c=q.cR():r,b,c)}else q.eM(b,c)},
eM(a,b){var s,r,q,p,o=this,n=A.w(o)
n.c.a(a)
n.z[1].a(b)
s=o.d
if(s==null)s=o.d=o.cR()
r=o.bI(a)
q=s[r]
if(q==null)s[r]=[o.cS(a,b)]
else{p=o.bJ(q,a)
if(p>=0)q[p].b=b
else q.push(o.cS(a,b))}},
kj(a,b){var s,r,q=this,p=A.w(q)
p.c.a(a)
p.l("2()").a(b)
if(q.a3(a)){s=q.q(0,a)
return s==null?p.z[1].a(s):s}r=b.$0()
q.h(0,a,r)
return r},
bP(a,b){if((b&0x3fffffff)===b)return this.ja(this.c,b)
else return this.eL(b)},
eL(a){var s,r,q,p,o=this,n=o.d
if(n==null)return null
s=o.bI(a)
r=n[s]
q=o.bJ(r,a)
if(q<0)return null
p=r.splice(q,1)[0]
o.eq(p)
if(r.length===0)delete n[s]
return p.b},
av(a,b){var s,r,q=this
A.w(q).l("~(1,2)").a(b)
s=q.e
r=q.r
for(;s!=null;){b.$2(s.a,s.b)
if(r!==q.r)throw A.d(A.ba(q))
s=s.c}},
dq(a,b,c){var s,r=A.w(this)
r.c.a(b)
r.z[1].a(c)
s=a[b]
if(s==null)a[b]=this.cS(b,c)
else s.b=c},
ja(a,b){var s
if(a==null)return null
s=a[b]
if(s==null)return null
this.eq(s)
delete a[b]
return s.b},
e4(){this.r=this.r+1&1073741823},
cS(a,b){var s=this,r=A.w(s),q=new A.hy(r.c.a(a),r.z[1].a(b))
if(s.e==null)s.e=s.f=q
else{r=s.f
r.toString
q.d=r
s.f=r.c=q}++s.a
s.e4()
return q},
eq(a){var s=this,r=a.d,q=a.c
if(r==null)s.e=q
else r.c=q
if(q==null)s.f=r
else q.d=r;--s.a
s.e4()},
bI(a){return J.dQ(a)&0x3fffffff},
bJ(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.au(a[r].a,b))return r
return-1},
u(a){return A.k2(this)},
cR(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s},
$ik0:1}
A.hw.prototype={
$1(a){var s=this.a,r=A.w(s)
s=s.q(0,r.c.a(a))
return s==null?r.z[1].a(s):s},
$S(){return A.w(this.a).l("2(1)")}}
A.hv.prototype={
$2(a,b){var s=this.a,r=A.w(s)
s.h(0,r.c.a(a),r.z[1].a(b))},
$S(){return A.w(this.a).l("~(1,2)")}}
A.hy.prototype={}
A.aA.prototype={
gv(a){return this.a.a},
gal(a){return this.a.a===0},
gZ(a){var s=this.a,r=new A.bE(s,s.r,this.$ti.l("bE<1>"))
r.c=s.e
return r}}
A.bE.prototype={
gH(){return this.d},
C(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.d(A.ba(q))
s=r.c
if(s==null){r.sdn(null)
return!1}else{r.sdn(s.a)
r.c=s.c
return!0}},
sdn(a){this.d=this.$ti.l("1?").a(a)},
$iI:1}
A.jF.prototype={
$1(a){return this.a(a)},
$S:12}
A.jG.prototype={
$2(a,b){return this.a(a,b)},
$S:46}
A.jH.prototype={
$1(a){return this.a(A.a_(a))},
$S:44}
A.et.prototype={
u(a){return"RegExp/"+this.a+"/"+this.b.flags},
$ihL:1,
$ilw:1}
A.iN.prototype={
K(){var s=this.b
if(s===this)throw A.d(new A.bD("Local '"+this.a+"' has not been initialized."))
return s},
bA(){var s=this.b
if(s===this)throw A.d(A.hx(this.a))
return s}}
A.cV.prototype={$icV:1}
A.N.prototype={
ib(a,b,c,d){var s=A.Q(b,0,c,d,null)
throw A.d(s)},
dE(a,b,c,d){if(b>>>0!==b||b>c)this.ib(a,b,c,d)},
$iN:1,
$iV:1}
A.U.prototype={
gv(a){return a.length},
ek(a,b,c,d,e){var s,r,q=a.length
this.dE(a,b,q,"start")
this.dE(a,c,q,"end")
if(b>c)throw A.d(A.Q(b,0,c,null,null))
s=c-b
if(e<0)throw A.d(A.bu(e,null))
r=d.length
if(r-e<s)throw A.d(A.hX("Not enough elements"))
if(e!==0||r!==s)d=d.subarray(e,e+s)
a.set(d,b)},
$iai:1}
A.bd.prototype={
q(a,b){A.aZ(b,a,a.length)
return a[b]},
h(a,b,c){A.o(b)
A.pg(c)
A.aZ(b,a,a.length)
a[b]=c},
U(a,b,c,d,e){t.id.a(d)
if(t.dQ.b(d)){this.ek(a,b,c,d,e)
return}this.dl(a,b,c,d,e)},
az(a,b,c,d){return this.U(a,b,c,d,0)},
$ir:1,
$ik:1,
$ih:1}
A.aj.prototype={
h(a,b,c){A.o(b)
A.o(c)
A.aZ(b,a,a.length)
a[b]=c},
U(a,b,c,d,e){t.fm.a(d)
if(t.aj.b(d)){this.ek(a,b,c,d,e)
return}this.dl(a,b,c,d,e)},
az(a,b,c,d){return this.U(a,b,c,d,0)},
$ir:1,
$ik:1,
$ih:1}
A.eD.prototype={
a9(a,b,c){return new Float32Array(a.subarray(b,A.aD(b,c,a.length)))},
$inq:1}
A.eE.prototype={
a9(a,b,c){return new Float64Array(a.subarray(b,A.aD(b,c,a.length)))}}
A.eF.prototype={
q(a,b){A.aZ(b,a,a.length)
return a[b]},
a9(a,b,c){return new Int16Array(a.subarray(b,A.aD(b,c,a.length)))},
$ijW:1}
A.eG.prototype={
q(a,b){A.aZ(b,a,a.length)
return a[b]},
a9(a,b,c){return new Int32Array(a.subarray(b,A.aD(b,c,a.length)))},
$iho:1}
A.eH.prototype={
q(a,b){A.aZ(b,a,a.length)
return a[b]},
a9(a,b,c){return new Int8Array(a.subarray(b,A.aD(b,c,a.length)))},
$inA:1}
A.eI.prototype={
q(a,b){A.aZ(b,a,a.length)
return a[b]},
a9(a,b,c){return new Uint16Array(a.subarray(b,A.aD(b,c,a.length)))},
$inY:1}
A.cW.prototype={
q(a,b){A.aZ(b,a,a.length)
return a[b]},
a9(a,b,c){return new Uint32Array(a.subarray(b,A.aD(b,c,a.length)))},
cq(a,b){return this.a9(a,b,null)},
$iaV:1}
A.cX.prototype={
gv(a){return a.length},
q(a,b){A.aZ(b,a,a.length)
return a[b]},
a9(a,b,c){return new Uint8ClampedArray(a.subarray(b,A.aD(b,c,a.length)))}}
A.bG.prototype={
gv(a){return a.length},
q(a,b){A.aZ(b,a,a.length)
return a[b]},
a9(a,b,c){return new Uint8Array(a.subarray(b,A.aD(b,c,a.length)))},
cq(a,b){return this.a9(a,b,null)},
$ibG:1,
$ibj:1}
A.du.prototype={}
A.dv.prototype={}
A.dw.prototype={}
A.dx.prototype={}
A.aB.prototype={
l(a){return A.jk(v.typeUniverse,this,a)},
G(a){return A.pc(v.typeUniverse,this,a)}}
A.fo.prototype={}
A.dD.prototype={
u(a){return A.al(this.a,null)},
$ilG:1}
A.fn.prototype={
u(a){return this.a}}
A.dE.prototype={$ibi:1}
A.iI.prototype={
$1(a){var s=this.a,r=s.a
s.a=null
r.$0()},
$S:16}
A.iH.prototype={
$1(a){var s,r
this.a.a=t.M.a(a)
s=this.b
r=this.c
s.firstChild?s.removeChild(r):s.appendChild(r)},
$S:43}
A.iJ.prototype={
$0(){this.a.$0()},
$S:7}
A.iK.prototype={
$0(){this.a.$0()},
$S:7}
A.ji.prototype={
fK(a,b){if(self.setTimeout!=null)self.setTimeout(A.bQ(new A.jj(this,b),0),a)
else throw A.d(A.Z("`setTimeout()` not found."))}}
A.jj.prototype={
$0(){this.b.$0()},
$S:1}
A.fj.prototype={
cj(a){var s,r=this,q=r.$ti
q.l("1/?").a(a)
if(a==null)q.c.a(a)
if(!r.b)r.a.cu(a)
else{s=r.a
if(q.l("ax<1>").b(a))s.dD(a)
else s.cC(q.c.a(a))}},
d3(a,b){var s=this.a
if(this.b)s.bv(a,b)
else s.dz(a,b)}}
A.jp.prototype={
$1(a){return this.a.$2(0,a)},
$S:4}
A.jq.prototype={
$2(a,b){this.a.$2(1,new A.cw(a,t.l.a(b)))},
$S:36}
A.jv.prototype={
$2(a,b){this.a(A.o(a),b)},
$S:33}
A.cg.prototype={
u(a){return"IterationMarker("+this.b+", "+A.v(this.a)+")"}}
A.bo.prototype={
gH(){var s,r=this.c
if(r==null){s=this.b
return s==null?this.$ti.c.a(s):s}return r.gH()},
C(){var s,r,q,p,o,n,m=this
for(s=m.$ti.l("I<1>");!0;){r=m.c
if(r!=null)if(r.C())return!0
else m.se7(null)
q=function(a,b,c){var l,k=b
while(true)try{return a(k,l)}catch(j){l=j
k=c}}(m.a,0,1)
if(q instanceof A.cg){p=q.b
if(p===2){o=m.d
if(o==null||o.length===0){m.sdw(null)
return!1}if(0>=o.length)return A.a(o,-1)
m.a=o.pop()
continue}else{r=q.a
if(p===3)throw r
else{n=s.a(J.aK(r))
if(n instanceof A.bo){r=m.d
if(r==null)r=m.d=[]
B.b.A(r,m.a)
m.a=n.a
continue}else{m.se7(n)
continue}}}}else{m.sdw(q)
return!0}}return!1},
sdw(a){this.b=this.$ti.l("1?").a(a)},
se7(a){this.c=this.$ti.l("I<1>?").a(a)},
$iI:1}
A.dC.prototype={
gZ(a){return new A.bo(this.a(),this.$ti.l("bo<1>"))}}
A.cr.prototype={
u(a){return A.v(this.a)},
$ix:1,
gbY(){return this.b}}
A.fm.prototype={
d3(a,b){var s
A.cl(a,"error",t.K)
s=this.a
if((s.a&30)!==0)throw A.d(A.hX("Future already completed"))
if(b==null)b=A.kN(a)
s.dz(a,b)},
eD(a){return this.d3(a,null)}}
A.bM.prototype={
cj(a){var s,r=this.$ti
r.l("1/?").a(a)
s=this.a
if((s.a&30)!==0)throw A.d(A.hX("Future already completed"))
s.cu(r.l("1/").a(a))},
jA(){return this.cj(null)}}
A.aY.prototype={
k6(a){if((this.c&15)!==6)return!0
return this.b.b.d9(t.nU.a(this.d),a.a,t.v,t.K)},
jZ(a){var s,r=this,q=r.e,p=null,o=t.z,n=t.K,m=a.a,l=r.b.b
if(t.C.b(q))p=l.kw(q,m,a.b,o,n,t.l)
else p=l.d9(t.E.a(q),m,o,n)
try{o=r.$ti.l("2/").a(p)
return o}catch(s){if(t.do.b(A.a0(s))){if((r.c&1)!==0)throw A.d(A.bu("The error handler of Future.then must return a value of the returned future's type","onError"))
throw A.d(A.bu("The error handler of Future.catchError must return a value of the future's type","onError"))}else throw s}}}
A.L.prototype={
da(a,b,c){var s,r,q,p=this.$ti
p.G(c).l("1/(2)").a(a)
s=$.C
if(s===B.h){if(b!=null&&!t.C.b(b)&&!t.E.b(b))throw A.d(A.bS(b,"onError",u.b))}else{c.l("@<0/>").G(p.c).l("1(2)").a(a)
if(b!=null)b=A.pG(b,s)}r=new A.L(s,c.l("L<0>"))
q=b==null?1:3
this.bZ(new A.aY(r,q,a,b,p.l("@<1>").G(c).l("aY<1,2>")))
return r},
kz(a,b){return this.da(a,null,b)},
en(a,b,c){var s,r=this.$ti
r.G(c).l("1/(2)").a(a)
s=new A.L($.C,c.l("L<0>"))
this.bZ(new A.aY(s,3,a,b,r.l("@<1>").G(c).l("aY<1,2>")))
return s},
jd(a){this.a=this.a&1|16
this.c=a},
cA(a){this.a=a.a&30|this.a&1
this.c=a.c},
bZ(a){var s,r=this,q=r.a
if(q<=3){a.a=t.F.a(r.c)
r.c=a}else{if((q&4)!==0){s=t.d.a(r.c)
if((s.a&24)===0){s.bZ(a)
return}r.cA(s)}A.bP(null,null,r.b,t.M.a(new A.iT(r,a)))}},
ec(a){var s,r,q,p,o,n,m=this,l={}
l.a=a
if(a==null)return
s=m.a
if(s<=3){r=t.F.a(m.c)
m.c=a
if(r!=null){q=a.a
for(p=a;q!=null;p=q,q=o)o=q.a
p.a=r}}else{if((s&4)!==0){n=t.d.a(m.c)
if((n.a&24)===0){n.ec(a)
return}m.cA(n)}l.a=m.cd(a)
A.bP(null,null,m.b,t.M.a(new A.j_(l,m)))}},
cc(){var s=t.F.a(this.c)
this.c=null
return this.cd(s)},
cd(a){var s,r,q
for(s=a,r=null;s!=null;r=s,s=q){q=s.a
s.a=r}return r},
hc(a){var s,r,q,p=this
p.a^=2
try{a.da(new A.iW(p),new A.iX(p),t.P)}catch(q){s=A.a0(q)
r=A.an(q)
A.qk(new A.iY(p,s,r))}},
cC(a){var s,r=this
r.$ti.c.a(a)
s=r.cc()
r.a=8
r.c=a
A.cf(r,s)},
bv(a,b){var s
t.l.a(b)
s=this.cc()
this.jd(A.fL(a,b))
A.cf(this,s)},
cu(a){var s=this.$ti
s.l("1/").a(a)
if(s.l("ax<1>").b(a)){this.dD(a)
return}this.h6(s.c.a(a))},
h6(a){var s=this
s.$ti.c.a(a)
s.a^=2
A.bP(null,null,s.b,t.M.a(new A.iV(s,a)))},
dD(a){var s=this,r=s.$ti
r.l("ax<1>").a(a)
if(r.b(a)){if((a.a&16)!==0){s.a^=2
A.bP(null,null,s.b,t.M.a(new A.iZ(s,a)))}else A.kj(a,s)
return}s.hc(a)},
dz(a,b){this.a^=2
A.bP(null,null,this.b,t.M.a(new A.iU(this,a,b)))},
$iax:1}
A.iT.prototype={
$0(){A.cf(this.a,this.b)},
$S:1}
A.j_.prototype={
$0(){A.cf(this.b,this.a.a)},
$S:1}
A.iW.prototype={
$1(a){var s,r,q,p=this.a
p.a^=2
try{p.cC(p.$ti.c.a(a))}catch(q){s=A.a0(q)
r=A.an(q)
p.bv(s,r)}},
$S:16}
A.iX.prototype={
$2(a,b){this.a.bv(t.K.a(a),t.l.a(b))},
$S:32}
A.iY.prototype={
$0(){this.a.bv(this.b,this.c)},
$S:1}
A.iV.prototype={
$0(){this.a.cC(this.b)},
$S:1}
A.iZ.prototype={
$0(){A.kj(this.b,this.a)},
$S:1}
A.iU.prototype={
$0(){this.a.bv(this.b,this.c)},
$S:1}
A.j2.prototype={
$0(){var s,r,q,p,o,n,m=this,l=null
try{q=m.a.a
l=q.b.b.eV(t.O.a(q.d),t.z)}catch(p){s=A.a0(p)
r=A.an(p)
q=m.c&&t.n.a(m.b.a.c).a===s
o=m.a
if(q)o.c=t.n.a(m.b.a.c)
else o.c=A.fL(s,r)
o.b=!0
return}if(l instanceof A.L&&(l.a&24)!==0){if((l.a&16)!==0){q=m.a
q.c=t.n.a(l.c)
q.b=!0}return}if(t.c.b(l)){n=m.b.a
q=m.a
q.c=l.kz(new A.j3(n),t.z)
q.b=!1}},
$S:1}
A.j3.prototype={
$1(a){return this.a},
$S:31}
A.j1.prototype={
$0(){var s,r,q,p,o,n,m,l
try{q=this.a
p=q.a
o=p.$ti
n=o.c
m=n.a(this.b)
q.c=p.b.b.d9(o.l("2/(1)").a(p.d),m,o.l("2/"),n)}catch(l){s=A.a0(l)
r=A.an(l)
q=this.a
q.c=A.fL(s,r)
q.b=!0}},
$S:1}
A.j0.prototype={
$0(){var s,r,q,p,o,n,m=this
try{s=t.n.a(m.a.a.c)
p=m.b
if(p.a.k6(s)&&p.a.e!=null){p.c=p.a.jZ(s)
p.b=!1}}catch(o){r=A.a0(o)
q=A.an(o)
p=t.n.a(m.a.a.c)
n=m.b
if(p.a===r)n.c=p
else n.c=A.fL(r,q)
n.b=!0}},
$S:1}
A.fk.prototype={}
A.cb.prototype={
gv(a){var s,r,q=this,p={},o=new A.L($.C,t.hy)
p.a=0
s=q.$ti
r=s.l("~(1)?").a(new A.hY(p,q))
t.Z.a(new A.hZ(p,o))
A.iQ(q.a,q.b,r,!1,s.c)
return o}}
A.hY.prototype={
$1(a){this.b.$ti.c.a(a);++this.a.a},
$S(){return this.b.$ti.l("~(1)")}}
A.hZ.prototype={
$0(){var s=this.b,r=s.$ti,q=r.l("1/").a(this.a.a),p=s.cc()
r.c.a(q)
s.a=8
s.c=q
A.cf(s,p)},
$S:1}
A.f_.prototype={}
A.f0.prototype={}
A.fu.prototype={}
A.dH.prototype={$ilR:1}
A.ju.prototype={
$0(){var s=this.a,r=this.b
A.cl(s,"error",t.K)
A.cl(r,"stackTrace",t.l)
A.ni(s,r)},
$S:1}
A.fs.prototype={
kx(a){var s,r,q
t.M.a(a)
try{if(B.h===$.C){a.$0()
return}A.mf(null,null,this,a,t.q)}catch(q){s=A.a0(q)
r=A.an(q)
A.jt(t.K.a(s),t.l.a(r))}},
ky(a,b,c){var s,r,q
c.l("~(0)").a(a)
c.a(b)
try{if(B.h===$.C){a.$1(b)
return}A.mg(null,null,this,a,b,t.q,c)}catch(q){s=A.a0(q)
r=A.an(q)
A.jt(t.K.a(s),t.l.a(r))}},
eA(a){return new A.jd(this,t.M.a(a))},
js(a,b){return new A.je(this,b.l("~(0)").a(a),b)},
eV(a,b){b.l("0()").a(a)
if($.C===B.h)return a.$0()
return A.mf(null,null,this,a,b)},
d9(a,b,c,d){c.l("@<0>").G(d).l("1(2)").a(a)
d.a(b)
if($.C===B.h)return a.$1(b)
return A.mg(null,null,this,a,b,c,d)},
kw(a,b,c,d,e,f){d.l("@<0>").G(e).G(f).l("1(2,3)").a(a)
e.a(b)
f.a(c)
if($.C===B.h)return a.$2(b,c)
return A.pH(null,null,this,a,b,c,d,e,f)},
eU(a,b,c,d){return b.l("@<0>").G(c).G(d).l("1(2,3)").a(a)}}
A.jd.prototype={
$0(){return this.a.kx(this.b)},
$S:1}
A.je.prototype={
$1(a){var s=this.c
return this.a.ky(this.b,s.a(a),s)},
$S(){return this.c.l("~(0)")}}
A.dp.prototype={
q(a,b){if(!A.b0(this.y.$1(b)))return null
return this.fn(b)},
h(a,b,c){var s=this.$ti
this.fp(s.c.a(b),s.z[1].a(c))},
a3(a){if(!A.b0(this.y.$1(a)))return!1
return this.fm(a)},
bP(a,b){if(!A.b0(this.y.$1(b)))return null
return this.fo(b)},
bI(a){return this.x.$1(this.$ti.c.a(a))&1073741823},
bJ(a,b){var s,r,q,p
if(a==null)return-1
s=a.length
for(r=this.$ti.c,q=this.w,p=0;p<s;++p)if(A.b0(q.$2(r.a(a[p].a),r.a(b))))return p
return-1}}
A.jc.prototype={
$1(a){return this.a.b(a)},
$S:5}
A.dq.prototype={
gZ(a){var s=this,r=new A.bN(s,s.r,s.$ti.l("bN<1>"))
r.c=s.e
return r},
gv(a){return this.a},
aB(a,b){var s,r
if(typeof b=="string"&&b!=="__proto__"){s=this.b
if(s==null)return!1
return t.g.a(s[b])!=null}else if(typeof b=="number"&&(b&1073741823)===b){r=this.c
if(r==null)return!1
return t.g.a(r[b])!=null}else return this.hf(b)},
hf(a){var s=this.d
if(s==null)return!1
return this.dO(s[J.dQ(a)&1073741823],a)>=0},
gaC(a){var s=this.e
if(s==null)throw A.d(A.hX("No elements"))
return this.$ti.c.a(s.a)},
A(a,b){var s,r,q=this
q.$ti.c.a(b)
if(typeof b=="string"&&b!=="__proto__"){s=q.b
return q.dF(s==null?q.b=A.kl():s,b)}else if(typeof b=="number"&&(b&1073741823)===b){r=q.c
return q.dF(r==null?q.c=A.kl():r,b)}else return q.hd(b)},
hd(a){var s,r,q,p=this
p.$ti.c.a(a)
s=p.d
if(s==null)s=p.d=A.kl()
r=J.dQ(a)&1073741823
q=s[r]
if(q==null)s[r]=[p.cB(a)]
else{if(p.dO(q,a)>=0)return!1
q.push(p.cB(a))}return!0},
dF(a,b){this.$ti.c.a(b)
if(t.g.a(a[b])!=null)return!1
a[b]=this.cB(b)
return!0},
cB(a){var s=this,r=new A.fr(s.$ti.c.a(a))
if(s.e==null)s.e=s.f=r
else s.f=s.f.b=r;++s.a
s.r=s.r+1&1073741823
return r},
dO(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.au(a[r].a,b))return r
return-1}}
A.fr.prototype={}
A.bN.prototype={
gH(){var s=this.d
return s==null?this.$ti.c.a(s):s},
C(){var s=this,r=s.c,q=s.a
if(s.b!==q.r)throw A.d(A.ba(q))
else if(r==null){s.sbu(null)
return!1}else{s.sbu(s.$ti.l("1?").a(r.a))
s.c=r.b
return!0}},
sbu(a){this.d=this.$ti.l("1?").a(a)},
$iI:1}
A.cM.prototype={}
A.hz.prototype={
$2(a,b){this.a.h(0,this.b.a(a),this.c.a(b))},
$S:17}
A.cS.prototype={$ir:1,$ik:1,$ih:1}
A.q.prototype={
gZ(a){return new A.bF(a,this.gv(a),A.S(a).l("bF<q.E>"))},
ar(a,b){return this.q(a,b)},
gal(a){return this.gv(a)===0},
geN(a){return this.gv(a)!==0},
gaC(a){if(this.gv(a)===0)throw A.d(A.bC())
return this.q(a,0)},
b8(a,b){var s,r
A.S(a).l("G(q.E)").a(b)
s=this.gv(a)
for(r=0;r<s;++r){if(!A.b0(b.$1(this.q(a,r))))return!1
if(s!==this.gv(a))throw A.d(A.ba(a))}return!0},
bb(a,b){var s=A.S(a)
return new A.W(a,s.l("G(q.E)").a(b),s.l("W<q.E>"))},
ba(a,b,c){var s=A.S(a)
return new A.aS(a,s.G(c).l("1(q.E)").a(b),s.l("@<q.E>").G(c).l("aS<1,2>"))},
di(a,b){return A.kd(a,b,null,A.S(a).l("q.E"))},
a7(a,b){var s,r,q,p,o=this
if(o.gv(a)===0){s=J.eq(0,A.S(a).l("q.E"))
return s}r=o.q(a,0)
q=A.H(o.gv(a),r,!0,A.S(a).l("q.E"))
for(p=1;p<o.gv(a);++p)B.b.h(q,p,o.q(a,p))
return q},
aP(a){return this.a7(a,!0)},
a9(a,b,c){var s,r=this.gv(a)
A.ab(b,c,r)
A.ab(b,c,this.gv(a))
s=A.S(a).l("q.E")
return A.lg(A.kd(a,b,c,s),s)},
ak(a,b,c,d){var s
A.S(a).l("q.E?").a(d)
A.ab(b,c,this.gv(a))
for(s=b;s<c;++s)this.h(a,s,d)},
U(a,b,c,d,e){var s,r,q,p,o=A.S(a)
o.l("k<q.E>").a(d)
A.ab(b,c,this.gv(a))
s=c-b
if(s===0)return
A.eX(e,"skipCount")
if(o.l("h<q.E>").b(d)){r=e
q=d}else{q=J.kM(d,e).a7(0,!1)
r=0}o=J.ae(q)
if(r+s>o.gv(q))throw A.d(A.l6())
if(r<b)for(p=s-1;p>=0;--p)this.h(a,b+p,o.q(q,r+p))
else for(p=0;p<s;++p)this.h(a,b+p,o.q(q,r+p))},
az(a,b,c,d){return this.U(a,b,c,d,0)},
f9(a,b,c){A.S(a).l("k<q.E>").a(c)
this.az(a,b,b+c.length,c)},
u(a){return A.jX(a,"[","]")}}
A.cT.prototype={}
A.hC.prototype={
$2(a,b){var s,r=this.a
if(!r.a)this.b.a+=", "
r.a=!1
r=this.b
s=r.a+=A.v(a)
r.a=s+": "
r.a+=A.v(b)},
$S:6}
A.Y.prototype={
av(a,b){var s,r,q,p=A.w(this)
p.l("~(Y.K,Y.V)").a(b)
for(s=this.gaN(),s=s.gZ(s),p=p.l("Y.V");s.C();){r=s.gH()
q=this.q(0,r)
b.$2(r,q==null?p.a(q):q)}},
gv(a){var s=this.gaN()
return s.gv(s)},
gal(a){var s=this.gaN()
return s.gal(s)},
gaG(){var s=A.w(this)
return new A.ds(this,s.l("@<Y.K>").G(s.l("Y.V")).l("ds<1,2>"))},
u(a){return A.k2(this)},
$iaa:1}
A.ds.prototype={
gv(a){var s=this.a
return s.gv(s)},
gaC(a){var s=this.a,r=s.gaN()
r=s.q(0,r.gaC(r))
return r==null?this.$ti.z[1].a(r):r},
gZ(a){var s=this.a,r=this.$ti,q=s.gaN()
return new A.dt(q.gZ(q),s,r.l("@<1>").G(r.z[1]).l("dt<1,2>"))}}
A.dt.prototype={
C(){var s=this,r=s.a
if(r.C()){s.sbu(s.b.q(0,r.gH()))
return!0}s.sbu(null)
return!1},
gH(){var s=this.c
return s==null?this.$ti.z[1].a(s):s},
sbu(a){this.c=this.$ti.l("2?").a(a)},
$iI:1}
A.d4.prototype={
a7(a,b){return A.hA(this,!0,this.$ti.c)},
aP(a){return this.a7(a,!0)},
ba(a,b,c){var s=this.$ti
return new A.by(this,s.G(c).l("1(2)").a(b),s.l("@<1>").G(c).l("by<1,2>"))},
u(a){return A.jX(this,"{","}")},
bb(a,b){var s=this.$ti
return new A.W(this,s.l("G(1)").a(b),s.l("W<1>"))},
gaC(a){var s,r=A.oY(this,this.r,this.$ti.c)
if(!r.C())throw A.d(A.bC())
s=r.d
return s==null?r.$ti.c.a(s):s}}
A.dz.prototype={$ir:1,$ik:1,$ika:1}
A.dr.prototype={}
A.dI.prototype={}
A.ib.prototype={
$0(){var s,r
try{s=new TextDecoder("utf-8",{fatal:true})
return s}catch(r){}return null},
$S:18}
A.ia.prototype={
$0(){var s,r
try{s=new TextDecoder("utf-8",{fatal:false})
return s}catch(r){}return null},
$S:18}
A.fy.prototype={
aY(a){var s,r,q=A.ab(0,null,a.length)-0,p=new Uint8Array(q)
for(s=0;s<q;++s){r=B.d.W(a,s)
if((r&4294967040)!==0)throw A.d(A.bS(a,"string","Contains invalid characters."))
if(!(s<q))return A.a(p,s)
p[s]=r}return p}}
A.fx.prototype={
aY(a){var s,r,q,p
t.L.a(a)
s=a.length
r=A.ab(0,null,s)
for(q=0;q<r;++q){if(!(q<s))return A.a(a,q)
p=a[q]
if((p&4294967040)!==0){if(!this.a)throw A.d(A.h4("Invalid value in input: "+p,null,null))
return this.hh(a,0,r)}}return A.i_(a,0,r)},
hh(a,b,c){var s,r,q,p
t.L.a(a)
for(s=a.length,r=b,q="";r<c;++r){if(!(r<s))return A.a(a,r)
p=a[r]
q+=A.B((p&4294967040)!==0?65533:p)}return q.charCodeAt(0)==0?q:q}}
A.dR.prototype={
fg(a){t.i3.a(a)
return new A.fB(new A.fD(new A.fC(!1),a,a.a),new A.iL("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"))}}
A.iL.prototype={
jE(a){return new Uint8Array(a)},
jP(a,b,c,d){var s,r,q,p,o=this
t.L.a(a)
s=(o.a&3)+(c-b)
r=B.a.F(s,3)
q=r*4
if(d&&s-r*3>0)q+=4
p=o.jE(q)
o.a=A.oT(o.b,a,b,c,d,p,0,o.a)
if(q>0)return p
return null}}
A.fl.prototype={}
A.fB.prototype={
h2(a,b,c,d){var s=this.b.jP(t.L.a(a),b,c,d)
if(s!=null)this.a.jq(s,0,s.length,d)}}
A.b7.prototype={}
A.dT.prototype={}
A.aL.prototype={$iaH:1}
A.av.prototype={}
A.aw.prototype={}
A.e1.prototype={}
A.cP.prototype={
u(a){var s=A.cv(this.a)
return(this.b!=null?"Converting object to an encodable object failed:":"Converting object did not return an encodable object:")+" "+s}}
A.ey.prototype={
u(a){return"Cyclic error in JSON stringify"}}
A.ex.prototype={
eI(a,b){var s
t.lN.a(b)
s=this.gd5()
s=A.lW(a,s.b,s.a)
return s},
gd5(){return B.b6}}
A.ez.prototype={}
A.ja.prototype={
dc(a){var s,r,q,p,o,n,m=a.length
for(s=this.c,r=0,q=0;q<m;++q){p=B.d.W(a,q)
if(p>92){if(p>=55296){o=p&64512
if(o===55296){n=q+1
n=!(n<m&&(B.d.W(a,n)&64512)===56320)}else n=!1
if(!n)if(o===56320){o=q-1
o=!(o>=0&&(B.d.aX(a,o)&64512)===55296)}else o=!1
else o=!0
if(o){if(q>r)s.a+=B.d.aT(a,r,q)
r=q+1
o=s.a+=A.B(92)
o+=A.B(117)
s.a=o
o+=A.B(100)
s.a=o
n=p>>>8&15
o+=A.B(n<10?48+n:87+n)
s.a=o
n=p>>>4&15
o+=A.B(n<10?48+n:87+n)
s.a=o
n=p&15
s.a=o+A.B(n<10?48+n:87+n)}}continue}if(p<32){if(q>r)s.a+=B.d.aT(a,r,q)
r=q+1
o=s.a+=A.B(92)
switch(p){case 8:s.a=o+A.B(98)
break
case 9:s.a=o+A.B(116)
break
case 10:s.a=o+A.B(110)
break
case 12:s.a=o+A.B(102)
break
case 13:s.a=o+A.B(114)
break
default:o+=A.B(117)
s.a=o
o+=A.B(48)
s.a=o
o+=A.B(48)
s.a=o
n=p>>>4&15
o+=A.B(n<10?48+n:87+n)
s.a=o
n=p&15
s.a=o+A.B(n<10?48+n:87+n)
break}}else if(p===34||p===92){if(q>r)s.a+=B.d.aT(a,r,q)
r=q+1
o=s.a+=A.B(92)
s.a=o+A.B(p)}}if(r===0)s.a+=a
else if(r<m)s.a+=B.d.aT(a,r,m)},
cw(a){var s,r,q,p
for(s=this.a,r=s.length,q=0;q<r;++q){p=s[q]
if(a==null?p==null:a===p)throw A.d(new A.ey(a,null))}B.b.A(s,a)},
bc(a){var s,r,q,p,o=this
if(o.f1(a))return
o.cw(a)
try{s=o.b.$1(a)
if(!o.f1(s)){q=A.ld(a,null,o.gea())
throw A.d(q)}q=o.a
if(0>=q.length)return A.a(q,-1)
q.pop()}catch(p){r=A.a0(p)
q=A.ld(a,r,o.gea())
throw A.d(q)}},
f1(a){var s,r,q=this
if(typeof a=="number"){if(!isFinite(a))return!1
q.c.a+=B.c.u(a)
return!0}else if(a===!0){q.c.a+="true"
return!0}else if(a===!1){q.c.a+="false"
return!0}else if(a==null){q.c.a+="null"
return!0}else if(typeof a=="string"){s=q.c
s.a+='"'
q.dc(a)
s.a+='"'
return!0}else if(t.j.b(a)){q.cw(a)
q.f2(a)
s=q.a
if(0>=s.length)return A.a(s,-1)
s.pop()
return!0}else if(t.f.b(a)){q.cw(a)
r=q.f3(a)
s=q.a
if(0>=s.length)return A.a(s,-1)
s.pop()
return r}else return!1},
f2(a){var s,r,q=this.c
q.a+="["
s=J.ae(a)
if(s.geN(a)){this.bc(s.q(a,0))
for(r=1;r<s.gv(a);++r){q.a+=","
this.bc(s.q(a,r))}}q.a+="]"},
f3(a){var s,r,q,p,o,n,m=this,l={}
if(a.gal(a)){m.c.a+="{}"
return!0}s=a.gv(a)*2
r=A.H(s,null,!1,t.X)
q=l.a=0
l.b=!0
a.av(0,new A.jb(l,r))
if(!l.b)return!1
p=m.c
p.a+="{"
for(o='"';q<s;q+=2,o=',"'){p.a+=o
m.dc(A.a_(r[q]))
p.a+='":'
n=q+1
if(!(n<s))return A.a(r,n)
m.bc(r[n])}p.a+="}"
return!0}}
A.jb.prototype={
$2(a,b){var s,r
if(typeof a!="string")this.a.b=!1
s=this.b
r=this.a
B.b.h(s,r.a++,a)
B.b.h(s,r.a++,b)},
$S:6}
A.j7.prototype={
f2(a){var s,r=this,q=J.ae(a),p=q.gal(a),o=r.c,n=o.a
if(p)o.a=n+"[]"
else{o.a=n+"[\n"
r.bU(++r.a$)
r.bc(q.q(a,0))
for(s=1;s<q.gv(a);++s){o.a+=",\n"
r.bU(r.a$)
r.bc(q.q(a,s))}o.a+="\n"
r.bU(--r.a$)
o.a+="]"}},
f3(a){var s,r,q,p,o,n,m=this,l={}
if(a.gal(a)){m.c.a+="{}"
return!0}s=a.gv(a)*2
r=A.H(s,null,!1,t.X)
q=l.a=0
l.b=!0
a.av(0,new A.j8(l,r))
if(!l.b)return!1
p=m.c
p.a+="{\n";++m.a$
for(o="";q<s;q+=2,o=",\n"){p.a+=o
m.bU(m.a$)
p.a+='"'
m.dc(A.a_(r[q]))
p.a+='": '
n=q+1
if(!(n<s))return A.a(r,n)
m.bc(r[n])}p.a+="\n"
m.bU(--m.a$)
p.a+="}"
return!0}}
A.j8.prototype={
$2(a,b){var s,r
if(typeof a!="string")this.a.b=!1
s=this.b
r=this.a
B.b.h(s,r.a++,a)
B.b.h(s,r.a++,b)},
$S:6}
A.fq.prototype={
gea(){var s=this.c.a
return s.charCodeAt(0)==0?s:s}}
A.j9.prototype={
bU(a){var s,r,q
for(s=this.f,r=this.c,q=0;q<a;++q)r.a+=s}}
A.eA.prototype={
cl(a){var s
t.L.a(a)
s=B.b7.aY(a)
return s}}
A.eC.prototype={}
A.eB.prototype={}
A.f1.prototype={}
A.f2.prototype={$iaH:1}
A.dB.prototype={}
A.fD.prototype={
jq(a,b,c,d){var s=this.c,r=this.a
s.a+=r.eE(t.L.a(a),b,c,!1)
if(d)r.jV(s)}}
A.fb.prototype={
gd5(){return B.aX}}
A.fd.prototype={
aY(a){var s,r,q=A.ab(0,null,a.length),p=q-0
if(p===0)return new Uint8Array(0)
s=new Uint8Array(p*3)
r=new A.jm(s)
if(r.hR(a,0,q)!==q){B.d.aX(a,q-1)
r.cZ()}return B.e.a9(s,0,r.b)}}
A.jm.prototype={
cZ(){var s=this,r=s.c,q=s.b,p=s.b=q+1,o=r.length
if(!(q<o))return A.a(r,q)
r[q]=239
q=s.b=p+1
if(!(p<o))return A.a(r,p)
r[p]=191
s.b=q+1
if(!(q<o))return A.a(r,q)
r[q]=189},
jn(a,b){var s,r,q,p,o,n=this
if((b&64512)===56320){s=65536+((a&1023)<<10)|b&1023
r=n.c
q=n.b
p=n.b=q+1
o=r.length
if(!(q<o))return A.a(r,q)
r[q]=s>>>18|240
q=n.b=p+1
if(!(p<o))return A.a(r,p)
r[p]=s>>>12&63|128
p=n.b=q+1
if(!(q<o))return A.a(r,q)
r[q]=s>>>6&63|128
n.b=p+1
if(!(p<o))return A.a(r,p)
r[p]=s&63|128
return!0}else{n.cZ()
return!1}},
hR(a,b,c){var s,r,q,p,o,n,m,l=this
if(b!==c&&(B.d.aX(a,c-1)&64512)===55296)--c
for(s=l.c,r=s.length,q=b;q<c;++q){p=B.d.W(a,q)
if(p<=127){o=l.b
if(o>=r)break
l.b=o+1
s[o]=p}else{o=p&64512
if(o===55296){if(l.b+4>r)break
n=q+1
if(l.jn(p,B.d.W(a,n)))q=n}else if(o===56320){if(l.b+3>r)break
l.cZ()}else if(p<=2047){o=l.b
m=o+1
if(m>=r)break
l.b=m
if(!(o<r))return A.a(s,o)
s[o]=p>>>6|192
l.b=m+1
s[m]=p&63|128}else{o=l.b
if(o+2>=r)break
m=l.b=o+1
if(!(o<r))return A.a(s,o)
s[o]=p>>>12|224
o=l.b=m+1
if(!(m<r))return A.a(s,m)
s[m]=p>>>6&63|128
l.b=o+1
if(!(o<r))return A.a(s,o)
s[o]=p&63|128}}}return q}}
A.fc.prototype={
aY(a){var s,r
t.L.a(a)
s=this.a
r=A.o1(s,a,0,null)
if(r!=null)return r
return new A.fC(s).eE(a,0,null,!0)}}
A.fC.prototype={
eE(a,b,c,d){var s,r,q,p,o,n,m=this
t.L.a(a)
s=A.ab(b,c,a.length)
if(b===s)return""
if(t.D.b(a)){r=a
q=0}else{r=A.pf(a,b,s)
s-=b
q=b
b=0}p=m.cD(r,b,s,d)
o=m.b
if((o&1)!==0){n=A.m2(o)
m.b=0
throw A.d(A.h4(n,a,q+m.c))}return p},
cD(a,b,c,d){var s,r,q=this
if(c-b>1000){s=B.a.F(b+c,2)
r=q.cD(a,b,s,!1)
if((q.b&1)!==0)return r
return r+q.cD(a,s,c,d)}return q.jJ(a,b,c,d)},
jV(a){var s=this.b
this.b=0
if(s<=32)return
if(this.a)a.a+=A.B(65533)
else throw A.d(A.h4(A.m2(77),null,null))},
jJ(a,b,c,d){var s,r,q,p,o,n,m,l,k=this,j=65533,i=k.b,h=k.c,g=new A.bh(""),f=b+1,e=a.length
if(!(b>=0&&b<e))return A.a(a,b)
s=a[b]
$label0$0:for(r=k.a;!0;){for(;!0;f=o){q=B.d.W("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFFFFFFFFFFFFFFFFGGGGGGGGGGGGGGGGHHHHHHHHHHHHHHHHHHHHHHHHHHHIHHHJEEBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBKCCCCCCCCCCCCDCLONNNMEEEEEEEEEEE",s)&31
h=i<=32?s&61694>>>q:(s&63|h<<6)>>>0
i=B.d.W(" \x000:XECCCCCN:lDb \x000:XECCCCCNvlDb \x000:XECCCCCN:lDb AAAAA\x00\x00\x00\x00\x00AAAAA00000AAAAA:::::AAAAAGG000AAAAA00KKKAAAAAG::::AAAAA:IIIIAAAAA000\x800AAAAA\x00\x00\x00\x00 AAAAA",i+q)
if(i===0){g.a+=A.B(h)
if(f===c)break $label0$0
break}else if((i&1)!==0){if(r)switch(i){case 69:case 67:g.a+=A.B(j)
break
case 65:g.a+=A.B(j);--f
break
default:p=g.a+=A.B(j)
g.a=p+A.B(j)
break}else{k.b=i
k.c=f-1
return""}i=0}if(f===c)break $label0$0
o=f+1
if(!(f>=0&&f<e))return A.a(a,f)
s=a[f]}o=f+1
if(!(f>=0&&f<e))return A.a(a,f)
s=a[f]
if(s<128){while(!0){if(!(o<c)){n=c
break}m=o+1
if(!(o>=0&&o<e))return A.a(a,o)
s=a[o]
if(s>=128){n=m-1
o=m
break}o=m}if(n-f<20)for(l=f;l<n;++l){if(!(l<e))return A.a(a,l)
g.a+=A.B(a[l])}else g.a+=A.i_(a,f,n)
if(n===c)break $label0$0
f=o}else f=o}if(d&&i>32)if(r)g.a+=A.B(j)
else{k.b=77
k.c=c
return""}k.b=i
k.c=h
e=g.a
return e.charCodeAt(0)==0?e:e}}
A.fE.prototype={}
A.bx.prototype={
br(a,b){if(b==null)return!1
return b instanceof A.bx&&this.a===b.a&&this.b===b.b},
gaf(a){var s=this.a
return(s^B.a.i(s,30))&1073741823},
kB(){if(this.b)return this
return A.nf(this.a,!0)},
u(a){var s=this,r=A.kU(A.eO(s)),q=A.aM(A.lr(s)),p=A.aM(A.ln(s)),o=A.aM(A.lo(s)),n=A.aM(A.lq(s)),m=A.aM(A.ls(s)),l=A.kV(A.lp(s)),k=r+"-"+q
if(s.b)return k+"-"+p+" "+o+":"+n+":"+m+"."+l+"Z"
else return k+"-"+p+" "+o+":"+n+":"+m+"."+l},
kA(){var s=this,r=A.eO(s)>=-9999&&A.eO(s)<=9999?A.kU(A.eO(s)):A.ng(A.eO(s)),q=A.aM(A.lr(s)),p=A.aM(A.ln(s)),o=A.aM(A.lo(s)),n=A.aM(A.lq(s)),m=A.aM(A.ls(s)),l=A.kV(A.lp(s)),k=r+"-"+q
if(s.b)return k+"-"+p+"T"+o+":"+n+":"+m+"."+l+"Z"
else return k+"-"+p+"T"+o+":"+n+":"+m+"."+l}}
A.iO.prototype={}
A.x.prototype={
gbY(){return A.an(this.$thrownJsError)}}
A.cq.prototype={
u(a){var s=this.a
if(s!=null)return"Assertion failed: "+A.cv(s)
return"Assertion failed"}}
A.bi.prototype={}
A.eJ.prototype={
u(a){return"Throw of null."}}
A.aF.prototype={
gcH(){return"Invalid argument"+(!this.a?"(s)":"")},
gcG(){return""},
u(a){var s=this,r=s.c,q=r==null?"":" ("+r+")",p=s.d,o=p==null?"":": "+A.v(p),n=s.gcH()+q+o
if(!s.a)return n
return n+s.gcG()+": "+A.cv(s.b)}}
A.d3.prototype={
gcH(){return"RangeError"},
gcG(){var s,r=this.e,q=this.f
if(r==null)s=q!=null?": Not less than or equal to "+A.v(q):""
else if(q==null)s=": Not greater than or equal to "+A.v(r)
else if(q>r)s=": Not in inclusive range "+A.v(r)+".."+A.v(q)
else s=q<r?": Valid value range is empty":": Only valid value is "+A.v(r)
return s}}
A.ec.prototype={
gcH(){return"RangeError"},
gcG(){if(A.o(this.b)<0)return": index must not be negative"
var s=this.f
if(s===0)return": no indices are valid"
return": index should be less than "+s},
gv(a){return this.f}}
A.fa.prototype={
u(a){return"Unsupported operation: "+this.a}}
A.f8.prototype={
u(a){var s=this.a
return s!=null?"UnimplementedError: "+s:"UnimplementedError"}}
A.ca.prototype={
u(a){return"Bad state: "+this.a}}
A.dY.prototype={
u(a){var s=this.a
if(s==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+A.cv(s)+"."}}
A.eK.prototype={
u(a){return"Out of Memory"},
gbY(){return null},
$ix:1}
A.d6.prototype={
u(a){return"Stack Overflow"},
gbY(){return null},
$ix:1}
A.dZ.prototype={
u(a){return"Reading static variable '"+this.a+"' during its initialization"}}
A.iS.prototype={
u(a){return"Exception: "+this.a}}
A.e6.prototype={
u(a){var s,r,q,p,o,n,m,l,k,j,i,h=this.a,g=""!==h?"FormatException: "+h:"FormatException",f=this.c,e=this.b
if(typeof e=="string"){if(f!=null)s=f<0||f>e.length
else s=!1
if(s)f=null
if(f==null){if(e.length>78)e=B.d.aT(e,0,75)+"..."
return g+"\n"+e}for(r=1,q=0,p=!1,o=0;o<f;++o){n=B.d.W(e,o)
if(n===10){if(q!==o||!p)++r
q=o+1
p=!1}else if(n===13){++r
q=o+1
p=!0}}g=r>1?g+(" (at line "+r+", character "+(f-q+1)+")\n"):g+(" (at character "+(f+1)+")\n")
m=e.length
for(o=f;o<m;++o){n=B.d.aX(e,o)
if(n===10||n===13){m=o
break}}if(m-q>78)if(f-q<75){l=q+75
k=q
j=""
i="..."}else{if(m-f<75){k=m-75
l=m
i=""}else{k=f-36
l=f+36
i="..."}j="..."}else{l=m
k=q
j=""
i=""}return g+j+B.d.aT(e,k,l)+i+"\n"+B.d.ap(" ",f-k+j.length)+"^\n"}else return f!=null?g+(" (at offset "+A.v(f)+")"):g}}
A.k.prototype={
ba(a,b,c){var s=A.w(this)
return A.k3(this,s.G(c).l("1(k.E)").a(b),s.l("k.E"),c)},
bb(a,b){var s=A.w(this)
return new A.W(this,s.l("G(k.E)").a(b),s.l("W<k.E>"))},
b8(a,b){var s
A.w(this).l("G(k.E)").a(b)
for(s=this.gZ(this);s.C();)if(!A.b0(b.$1(s.gH())))return!1
return!0},
a7(a,b){return A.hA(this,!0,A.w(this).l("k.E"))},
aP(a){return this.a7(a,!0)},
gv(a){var s,r=this.gZ(this)
for(s=0;r.C();)++s
return s},
gal(a){return!this.gZ(this).C()},
gaC(a){var s=this.gZ(this)
if(!s.C())throw A.d(A.bC())
return s.gH()},
ar(a,b){var s,r,q
A.eX(b,"index")
for(s=this.gZ(this),r=0;s.C();){q=s.gH()
if(b===r)return q;++r}throw A.d(A.hn(b,this,"index",null,r))},
u(a){return A.nB(this,"(",")")}}
A.dn.prototype={
ar(a,b){var s=this.a
if(0>b||b>=s)A.F(A.hn(b,this,"index",null,s))
return this.b.$1(b)},
gv(a){return this.a}}
A.I.prototype={}
A.K.prototype={
gaf(a){return A.t.prototype.gaf.call(this,this)},
u(a){return"null"}}
A.t.prototype={$it:1,
br(a,b){return this===b},
gaf(a){return A.d_(this)},
u(a){return"Instance of '"+A.hP(this)+"'"},
toString(){return this.u(this)}}
A.fv.prototype={
u(a){return""},
$ibg:1}
A.bh.prototype={
gv(a){return this.a.length},
u(a){var s=this.a
return s.charCodeAt(0)==0?s:s},
$ilE:1}
A.i8.prototype={
u(a){var s,r=this.b
if(0>=r.length)return A.a(r,0)
s=this.a
return r[0]===-1?"data:"+s:s}}
A.i9.prototype={
$2(a,b){var s,r,q
A.a_(a)
A.a_(b)
if(a.length===0)throw A.d(A.bS("","Parameter names must not be empty",null))
if(b.length===0)throw A.d(A.bS("","Parameter values must not be empty",'parameters["'+a+'"]'))
s=this.a
r=this.b
B.b.A(s,r.a.length)
r.a+=";"
q=r.a+=A.jl(B.L,a,B.t,!1)
B.b.A(s,q.length)
r.a+="="
r.a+=A.jl(B.L,b,B.t,!1)},
$S:25}
A.bw.prototype={$ibw:1}
A.bY.prototype={$ibY:1}
A.h_.prototype={
u(a){return String(a)}}
A.i.prototype={$ii:1}
A.aN.prototype={
d_(a,b,c,d){t.y.a(c)
if(c!=null)this.h3(a,b,c,!1)},
h3(a,b,c,d){return a.addEventListener(b,A.bQ(t.y.a(c),1),!1)},
j9(a,b,c,d){return a.removeEventListener(b,A.bQ(t.y.a(c),1),!1)},
$iaN:1}
A.c_.prototype={$ic_:1}
A.aT.prototype={$iaT:1}
A.bc.prototype={
d_(a,b,c,d){t.y.a(c)
if(b==="message")a.start()
this.fk(a,b,c,!1)},
eQ(a,b,c){t.nW.a(c)
if(c!=null){this.iD(a,new A.fw([],[]).aQ(b),c)
return}a.postMessage(new A.fw([],[]).aQ(b))
return},
kf(a,b){return this.eQ(a,b,null)},
iD(a,b,c){return a.postMessage(b,t.ez.a(c))},
$ibc:1}
A.bm.prototype={}
A.jR.prototype={}
A.iP.prototype={}
A.dm.prototype={
d1(){var s,r=this,q=r.b
if(q==null)return $.kH()
s=r.d
if(s!=null)J.mZ(q,r.c,t.y.a(s),!1)
r.b=null
r.siq(null)
return $.kH()},
siq(a){this.d=t.y.a(a)}}
A.iR.prototype={
$1(a){return this.a.$1(t.V.a(a))},
$S:24}
A.jf.prototype={
bl(a){var s,r=this.a,q=r.length
for(s=0;s<q;++s)if(r[s]===a)return s
B.b.A(r,a)
B.b.A(this.b,null)
return q},
aQ(a){var s,r,q,p=this,o={}
if(a==null)return a
if(A.dJ(a))return a
if(typeof a=="number")return a
if(typeof a=="string")return a
if(a instanceof A.bx)return new Date(a.a)
if(t.kl.b(a))throw A.d(A.da("structured clone of RegExp"))
if(t.et.b(a))return a
if(t.fj.b(a))return a
if(t.hH.b(a)||t.hX.b(a)||t.oA.b(a))return a
if(t.f.b(a)){s=p.bl(a)
r=p.b
if(!(s<r.length))return A.a(r,s)
q=o.a=r[s]
if(q!=null)return q
q={}
o.a=q
B.b.h(r,s,q)
a.av(0,new A.jg(o,p))
return o.a}if(t.j.b(a)){s=p.bl(a)
o=p.b
if(!(s<o.length))return A.a(o,s)
q=o[s]
if(q!=null)return q
return p.jD(a,s)}if(t.bp.b(a)){s=p.bl(a)
r=p.b
if(!(s<r.length))return A.a(r,s)
q=o.b=r[s]
if(q!=null)return q
q={}
o.b=q
B.b.h(r,s,q)
p.jX(a,new A.jh(o,p))
return o.b}throw A.d(A.da("structured clone of other type"))},
jD(a,b){var s,r=J.ae(a),q=r.gv(a),p=new Array(q)
B.b.h(this.b,b,p)
for(s=0;s<q;++s)B.b.h(p,s,this.aQ(r.q(a,s)))
return p}}
A.jg.prototype={
$2(a,b){this.a.a[a]=this.b.aQ(b)},
$S:17}
A.jh.prototype={
$2(a,b){this.a.b[a]=this.b.aQ(b)},
$S:23}
A.iF.prototype={
bl(a){var s,r=this.a,q=r.length
for(s=0;s<q;++s)if(r[s]===a)return s
B.b.A(r,a)
B.b.A(this.b,null)
return q},
aQ(a){var s,r,q,p,o,n,m,l,k,j=this,i={}
if(a==null)return a
if(A.dJ(a))return a
if(typeof a=="number")return a
if(typeof a=="string")return a
if(a instanceof Date){s=a.getTime()
if(Math.abs(s)<=864e13)r=!1
else r=!0
if(r)A.F(A.bu("DateTime is outside valid range: "+s,null))
A.cl(!0,"isUtc",t.v)
return new A.bx(s,!0)}if(a instanceof RegExp)throw A.d(A.da("structured clone of RegExp"))
if(typeof Promise!="undefined"&&a instanceof Promise)return A.qh(a,t.z)
q=Object.getPrototypeOf(a)
if(q===Object.prototype||q===null){p=j.bl(a)
r=j.b
if(!(p<r.length))return A.a(r,p)
o=i.a=r[p]
if(o!=null)return o
n=t.z
o=A.J(n,n)
i.a=o
B.b.h(r,p,o)
j.jW(a,new A.iG(i,j))
return i.a}if(a instanceof Array){m=a
p=j.bl(m)
r=j.b
if(!(p<r.length))return A.a(r,p)
o=r[p]
if(o!=null)return o
n=J.ae(m)
l=n.gv(m)
o=j.c?new Array(l):m
B.b.h(r,p,o)
for(r=J.R(o),k=0;k<l;++k)r.h(o,k,j.aQ(n.q(m,k)))
return o}return a},
eF(a,b){this.c=!0
return this.aQ(a)}}
A.iG.prototype={
$2(a,b){var s=this.a.a,r=this.b.aQ(b)
J.n(s,a,r)
return r},
$S:48}
A.fw.prototype={
jX(a,b){var s,r,q,p
t.p1.a(b)
for(s=Object.keys(a),r=s.length,q=0;q<r;++q){p=s[q]
b.$2(p,a[p])}}}
A.fh.prototype={
jW(a,b){var s,r,q,p
t.p1.a(b)
for(s=Object.keys(a),r=s.length,q=0;q<s.length;s.length===r||(0,A.b3)(s),++q){p=s[q]
b.$2(p,a[p])}}}
A.jN.prototype={
$1(a){return this.a.cj(this.b.l("0/?").a(a))},
$S:4}
A.jO.prototype={
$1(a){if(a==null)return this.a.eD(new A.hG(a===undefined))
return this.a.eD(a)},
$S:4}
A.hG.prototype={
u(a){return"Promise was rejected with a value of `"+(this.a?"undefined":"null")+"`."}}
A.fJ.prototype={}
A.ef.prototype={}
A.ee.prototype={
gv(a){var s=this.e
s===$&&A.c("_length")
return s-(this.b-this.c)},
gbK(){var s=this.b,r=this.e
r===$&&A.c("_length")
return s>=this.c+r},
t(){var s=this.a,r=this.b++
if(!(r>=0&&r<s.length))return A.a(s,r)
return s[r]},
a_(a){var s,r,q,p=this,o=p.c,n=p.b-o+o
if(a<0){s=p.e
s===$&&A.c("_length")
r=s-(n-o)}else r=a
q=A.bB(p.a,p.d,r,n)
p.b=p.b+q.gv(q)
return q},
j(){var s,r,q,p,o=this,n=o.a,m=o.b,l=o.b=m+1,k=n.length
if(!(m>=0&&m<k))return A.a(n,m)
m=n[m]
if(typeof m!=="number")return m.a0()
s=m&255
m=o.b=l+1
if(!(l>=0&&l<k))return A.a(n,l)
l=n[l]
if(typeof l!=="number")return l.a0()
r=l&255
l=o.b=m+1
if(!(m>=0&&m<k))return A.a(n,m)
m=n[m]
if(typeof m!=="number")return m.a0()
q=m&255
o.b=l+1
if(!(l>=0&&l<k))return A.a(n,l)
l=n[l]
if(typeof l!=="number")return l.a0()
p=l&255
if(o.d===1)return(s<<24|r<<16|q<<8|p)>>>0
return(p<<24|q<<16|r<<8|s)>>>0},
S(){var s,r,q,p,o=this,n=o.gv(o),m=o.a
if(t.D.b(m)){s=o.b
r=m.length
if(s+n>r)n=r-s
return A.z(m.buffer,m.byteOffset+s,n)}s=o.b
q=s+n
p=m.length
return new Uint8Array(A.b_(J.fI(m,s,q>p?p:q)))}}
A.hK.prototype={}
A.hI.prototype={
n(a){var s,r,q=this
if(q.a===q.c.length)q.ir()
s=q.c
r=q.a++
if(!(r>=0&&r<s.length))return A.a(s,r)
s[r]=a&255},
bT(a,b){var s,r,q,p,o=this
t.L.a(a)
if(b==null)b=a.length
for(;s=o.a,r=s+b,q=o.c,p=q.length,r>p;)o.cT(r-p)
B.e.az(q,s,r,a)
o.a+=b},
T(a){return this.bT(a,null)},
kJ(a){var s,r,q,p,o=this,n=a.c
while(!0){s=o.a
r=a.e
r===$&&A.c("_length")
r=s+(r-(a.b-n))
q=o.c
p=q.length
if(!(r>p))break
o.cT(r-p)}B.e.U(q,s,s+a.gv(a),a.a,a.b)
o.a=o.a+a.gv(a)},
P(a){var s=this
if(s.b===1){s.n(a>>>24&255)
s.n(a>>>16&255)
s.n(a>>>8&255)
s.n(a&255)
return}s.n(a&255)
s.n(a>>>8&255)
s.n(a>>>16&255)
s.n(a>>>24&255)},
dj(a,b){var s=this
if(a<0)a=s.a+a
if(b==null)b=s.a
else if(b<0)b=s.a+b
return A.z(s.c.buffer,a,b-a)},
R(a){return this.dj(a,null)},
cT(a){var s=a!=null?a>32768?a:32768:32768,r=this.c,q=r.length,p=new Uint8Array((q+s)*2)
B.e.az(p,0,q,r)
this.c=p},
ir(){return this.cT(null)},
gv(a){return this.a}}
A.jo.prototype={
bG(a,b){var s,r,q,p,o=a.t(),n=a.t(),m=o&8
B.a.i(o,3)
if(m!==8)throw A.d(A.cp("Only DEFLATE compression supported: "+m))
if(B.a.I((o<<8>>>0)+n,31)!==0)throw A.d(A.cp("Invalid FCHECK"))
if((n>>>5&1)!==0){a.j()
throw A.d(A.cp("FDICT Encoding not currently supported"))}s=A.c1(B.a8)
r=A.c1(B.ar)
q=A.hJ(0,null)
r=new A.ed(a,q,s,r)
r.b=!0
r.dY()
p=t.L.a(A.z(q.c.buffer,0,q.a))
a.j()
return p}}
A.fY.prototype={
hD(a){var s,r,q,p,o=this
if(a>4||!1)throw A.d(A.cp("Invalid Deflate Parameter"))
s=o.x
s===$&&A.c("_pending")
if(s!==0)o.c6()
if(o.c.gbK()){s=o.k3
s===$&&A.c("_lookAhead")
if(s===0)s=a!==0&&o.e!==666
else s=!0}else s=!0
if(s){switch($.ao.bA().e){case 0:r=o.hG(a)
break
case 1:r=o.hE(a)
break
case 2:r=o.hF(a)
break
default:r=-1
break}s=r===2
if(s||r===3)o.e=666
if(r===0||s)return 0
if(r===1){if(a===1){o.a1(2,3)
o.bj(256,B.I)
o.ez()
s=o.aM
s===$&&A.c("_lastEOBLen")
q=o.aj
q===$&&A.c("_numValidBits")
if(1+s+10-q<9){o.a1(2,3)
o.bj(256,B.I)
o.ez()}o.aM=7}else{o.eo(0,0,!1)
if(a===3){s=o.db
s===$&&A.c("_hashSize")
q=o.cx
p=0
for(;p<s;++p){q===$&&A.c("_head")
if(!(p<q.length))return A.a(q,p)
q[p]=0}}}o.c6()}}if(a!==4)return 0
return 1},
ik(){var s,r,q,p=this,o=p.as
o===$&&A.c("_windowSize")
p.ch=2*o
o=p.cx
o===$&&A.c("_head")
s=p.db
s===$&&A.c("_hashSize");--s
r=o.length
if(!(s>=0&&s<r))return A.a(o,s)
o[s]=0
for(q=0;q<s;++q){if(!(q<r))return A.a(o,q)
o[q]=0}p.k3=p.fx=p.k1=0
p.fy=p.k4=2
p.cy=p.id=0},
dZ(){var s,r,q,p,o=this,n="_dynamicLengthTree"
for(s=o.p2,r=0;r<286;++r){s===$&&A.c(n)
q=r*2
if(!(q<1146))return A.a(s,q)
s[q]=0}for(q=o.p3,r=0;r<30;++r){q===$&&A.c("_dynamicDistTree")
p=r*2
if(!(p<122))return A.a(q,p)
q[p]=0}for(q=o.p4,r=0;r<19;++r){q===$&&A.c("_bitLengthTree")
p=r*2
if(!(p<78))return A.a(q,p)
q[p]=0}s===$&&A.c(n)
s[512]=1
o.ai=o.aZ=o.ab=o.aL=0},
cU(a,b){var s,r,q,p,o,n=this.to
if(!(b>=0&&b<573))return A.a(n,b)
s=n[b]
r=b<<1>>>0
q=this.xr
while(!0){p=this.x1
p===$&&A.c("_heapLen")
if(!(r<=p))break
if(r<p){p=r+1
if(!(p>=0&&p<573))return A.a(n,p)
p=n[p]
if(!(r>=0&&r<573))return A.a(n,r)
p=A.kW(a,p,n[r],q)}else p=!1
if(p)++r
if(!(r>=0&&r<573))return A.a(n,r)
if(A.kW(a,s,n[r],q))break
p=n[r]
if(!(b>=0&&b<573))return A.a(n,b)
n[b]=p
o=r<<1>>>0
b=r
r=o}if(!(b>=0&&b<573))return A.a(n,b)
n[b]=s},
ei(a,b){var s,r,q,p,o,n,m,l,k,j="_bitLengthTree",i=a.length
if(1>=i)return A.a(a,1)
s=a[1]
if(s===0){r=138
q=3}else{r=7
q=4}p=(b+1)*2+1
if(!(p>=0&&p<i))return A.a(a,p)
a[p]=65535
for(p=this.p4,o=0,n=-1,m=0;o<=b;s=k){++o
l=o*2+1
if(!(l<i))return A.a(a,l)
k=a[l];++m
if(m<r&&s===k)continue
else if(m<q){p===$&&A.c(j)
l=s*2
if(!(l>=0&&l<78))return A.a(p,l)
p[l]=p[l]+m}else if(s!==0){if(s!==n){p===$&&A.c(j)
l=s*2
if(!(l>=0&&l<78))return A.a(p,l)
p[l]=p[l]+1}p===$&&A.c(j)
p[32]=p[32]+1}else if(m<=10){p===$&&A.c(j)
p[34]=p[34]+1}else{p===$&&A.c(j)
p[36]=p[36]+1}if(k===0){r=138
q=3}else if(s===k){r=6
q=3}else{r=7
q=4}n=s
m=0}},
h8(){var s,r,q=this,p=q.p2
p===$&&A.c("_dynamicLengthTree")
s=q.R8.b
s===$&&A.c("maxCode")
q.ei(p,s)
s=q.p3
s===$&&A.c("_dynamicDistTree")
p=q.RG.b
p===$&&A.c("maxCode")
q.ei(s,p)
q.rx.cv(q)
for(p=q.p4,r=18;r>=3;--r){p===$&&A.c("_bitLengthTree")
s=B.M[r]*2+1
if(!(s<78))return A.a(p,s)
if(p[s]!==0)break}p=q.ab
p===$&&A.c("_optimalLen")
q.ab=p+(3*(r+1)+5+5+4)
return r},
jc(a,b,c){var s,r,q,p,o=this
o.a1(a-257,5)
s=b-1
o.a1(s,5)
o.a1(c-4,4)
for(r=0;r<c;++r){q=o.p4
q===$&&A.c("_bitLengthTree")
if(!(r<19))return A.a(B.M,r)
p=B.M[r]*2+1
if(!(p<78))return A.a(q,p)
o.a1(q[p],3)}q=o.p2
q===$&&A.c("_dynamicLengthTree")
o.ej(q,a-1)
q=o.p3
q===$&&A.c("_dynamicDistTree")
o.ej(q,s)},
ej(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g=this,f="_bitLengthTree",e=a.length
if(1>=e)return A.a(a,1)
s=a[1]
if(s===0){r=138
q=3}else{r=7
q=4}for(p=t.L,o=0,n=-1,m=0;o<=b;s=k){++o
l=o*2+1
if(!(l<e))return A.a(a,l)
k=a[l];++m
if(m<r&&s===k)continue
else if(m<q){l=s*2
j=l+1
do{i=g.p4
i===$&&A.c(f)
p.a(i)
if(!(l>=0&&l<78))return A.a(i,l)
h=i[l]
if(!(j>=0&&j<78))return A.a(i,j)
g.a1(h&65535,i[j]&65535)}while(--m,m!==0)}else if(s!==0){if(s!==n){l=g.p4
l===$&&A.c(f)
p.a(l)
j=s*2
if(!(j>=0&&j<78))return A.a(l,j)
i=l[j];++j
if(!(j<78))return A.a(l,j)
g.a1(i&65535,l[j]&65535);--m}l=g.p4
l===$&&A.c(f)
p.a(l)
g.a1(l[32]&65535,l[33]&65535)
g.a1(m-3,2)}else{l=g.p4
if(m<=10){l===$&&A.c(f)
p.a(l)
g.a1(l[34]&65535,l[35]&65535)
g.a1(m-3,3)}else{l===$&&A.c(f)
p.a(l)
g.a1(l[36]&65535,l[37]&65535)
g.a1(m-11,7)}}if(k===0){r=138
q=3}else if(s===k){r=6
q=3}else{r=7
q=4}n=s
m=0}},
iK(a,b,c){var s,r,q=this
if(c===0)return
s=q.f
s===$&&A.c("_pendingBuffer")
r=q.x
r===$&&A.c("_pending")
B.e.U(s,r,r+c,a,b)
q.x=q.x+c},
ag(a){var s,r=this.f
r===$&&A.c("_pendingBuffer")
s=this.x
s===$&&A.c("_pending")
this.x=s+1
if(!(s>=0&&s<r.length))return A.a(r,s)
r[s]=a},
bj(a,b){var s,r,q
t.L.a(b)
s=a*2
r=b.length
if(!(s>=0&&s<r))return A.a(b,s)
q=b[s];++s
if(!(s<r))return A.a(b,s)
this.a1(q&65535,b[s]&65535)},
a1(a,b){var s,r=this,q="_bitBuffer",p=r.aj
p===$&&A.c("_numValidBits")
s=r.ae
if(p>16-b){s===$&&A.c(q)
p=r.ae=(s|B.a.D(a,p)&65535)>>>0
r.ag(p)
r.ag(A.ad(p,8))
p=r.aj
r.ae=A.ad(a,16-p)
r.aj=p+(b-16)}else{s===$&&A.c(q)
r.ae=(s|B.a.D(a,p)&65535)>>>0
r.aj=p+b}},
bC(a,b){var s,r,q,p,o,n,m=this,l="_dynamicLengthTree",k="_matches",j="_dynamicDistTree",i=m.f
i===$&&A.c("_pendingBuffer")
s=m.au
s===$&&A.c("_dbuf")
r=m.ai
r===$&&A.c("_lastLit")
s+=r*2
q=A.ad(a,8)
p=i.length
if(!(s<p))return A.a(i,s)
i[s]=q;++s
if(!(s<p))return A.a(i,s)
i[s]=a
s=m.y1
s===$&&A.c("_lbuf")
s+=r
if(!(s<p))return A.a(i,s)
i[s]=b
m.ai=r+1
if(a===0){i=m.p2
i===$&&A.c(l)
s=b*2
if(!(s>=0&&s<1146))return A.a(i,s)
i[s]=i[s]+1}else{i=m.aZ
i===$&&A.c(k)
m.aZ=i+1
i=m.p2
i===$&&A.c(l)
if(!(b>=0&&b<256))return A.a(B.W,b)
s=(B.W[b]+256+1)*2
if(!(s<1146))return A.a(i,s)
i[s]=i[s]+1
s=m.p3
s===$&&A.c(j)
i=A.lT(a-1)*2
if(!(i<122))return A.a(s,i)
s[i]=s[i]+1}i=m.ai
if((i&8191)===0){s=m.ok
s===$&&A.c("_level")
s=s>2}else s=!1
if(s){o=i*8
s=m.k1
s===$&&A.c("_strStart")
r=m.fx
r===$&&A.c("_blockStart")
for(q=m.p3,n=0;n<30;++n){q===$&&A.c(j)
p=n*2
if(!(p<122))return A.a(q,p)
o+=q[p]*(5+B.w[n])}o=A.ad(o,3)
q=m.aZ
q===$&&A.c(k)
if(q<i/2&&o<(s-r)/2)return!0}s=m.y2
s===$&&A.c("_litBufferSize")
return i===s-1},
dG(a,b){var s,r,q,p,o,n,m,l,k=this,j=t.L
j.a(a)
j.a(b)
j=k.ai
j===$&&A.c("_lastLit")
if(j!==0){s=0
do{j=k.f
j===$&&A.c("_pendingBuffer")
r=k.au
r===$&&A.c("_dbuf")
r+=s*2
q=j.length
if(!(r<q))return A.a(j,r)
p=j[r];++r
if(!(r<q))return A.a(j,r)
o=p<<8&65280|j[r]&255
r=k.y1
r===$&&A.c("_lbuf")
r+=s
if(!(r<q))return A.a(j,r)
n=j[r]&255;++s
if(o===0)k.bj(n,a)
else{m=B.W[n]
k.bj(m+256+1,a)
if(!(m<29))return A.a(B.Y,m)
l=B.Y[m]
if(l!==0)k.a1(n-B.er[m],l);--o
m=A.lT(o)
k.bj(m,b)
if(!(m<30))return A.a(B.w,m)
l=B.w[m]
if(l!==0)k.a1(o-B.cL[m],l)}}while(s<k.ai)}k.bj(256,a)
if(513>=a.length)return A.a(a,513)
k.aM=a[513]},
fa(){var s,r,q,p,o,n="_dynamicLengthTree"
for(s=this.p2,r=0,q=0;r<7;){s===$&&A.c(n)
p=r*2
if(!(p<1146))return A.a(s,p)
q+=s[p];++r}for(o=0;r<128;){s===$&&A.c(n)
p=r*2
if(!(p<1146))return A.a(s,p)
o+=s[p];++r}for(;r<256;){s===$&&A.c(n)
p=r*2
if(!(p<1146))return A.a(s,p)
q+=s[p];++r}this.y=q>A.ad(o,2)?0:1},
ez(){var s=this,r="_bitBuffer",q=s.aj
q===$&&A.c("_numValidBits")
if(q===16){q=s.ae
q===$&&A.c(r)
s.ag(q)
s.ag(A.ad(q,8))
s.aj=s.ae=0}else if(q>=8){q=s.ae
q===$&&A.c(r)
s.ag(q)
s.ae=A.ad(s.ae,8)
s.aj=s.aj-8}},
dA(){var s=this,r="_bitBuffer",q=s.aj
q===$&&A.c("_numValidBits")
if(q>8){q=s.ae
q===$&&A.c(r)
s.ag(q)
s.ag(A.ad(q,8))}else if(q>0){q=s.ae
q===$&&A.c(r)
s.ag(q)}s.aj=s.ae=0},
aV(a){var s,r,q,p,o,n=this,m=n.fx
m===$&&A.c("_blockStart")
if(m>=0)s=m
else s=-1
r=n.k1
r===$&&A.c("_strStart")
m=r-m
r=n.ok
r===$&&A.c("_level")
if(r>0){if(n.y===2)n.fa()
n.R8.cv(n)
n.RG.cv(n)
q=n.h8()
r=n.ab
r===$&&A.c("_optimalLen")
p=A.ad(r+3+7,3)
r=n.aL
r===$&&A.c("_staticLen")
o=A.ad(r+3+7,3)
if(o<=p)p=o}else{o=m+5
p=o
q=0}if(m+4<=p&&s!==-1)n.eo(s,m,a)
else if(o===p){n.a1(2+(a?1:0),3)
n.dG(B.I,B.ay)}else{n.a1(4+(a?1:0),3)
m=n.R8.b
m===$&&A.c("maxCode")
s=n.RG.b
s===$&&A.c("maxCode")
n.jc(m+1,s+1,q+1)
s=n.p2
s===$&&A.c("_dynamicLengthTree")
m=n.p3
m===$&&A.c("_dynamicDistTree")
n.dG(s,m)}n.dZ()
if(a)n.dA()
n.fx=n.k1
n.c6()},
hG(a){var s,r,q,p,o,n=this,m=n.r
m===$&&A.c("_pendingBufferSize")
s=m-5
s=65535>s?s:65535
for(m=a===0;!0;){r=n.k3
r===$&&A.c("_lookAhead")
if(r<=1){n.cJ()
r=n.k3
q=r===0
if(q&&m)return 0
if(q)break}q=n.k1
q===$&&A.c("_strStart")
r=n.k1=q+r
n.k3=0
q=n.fx
q===$&&A.c("_blockStart")
p=q+s
if(r>=p){n.k3=r-p
n.k1=p
n.aV(!1)}r=n.k1
q=n.fx
o=n.as
o===$&&A.c("_windowSize")
if(r-q>=o-262)n.aV(!1)}m=a===4
n.aV(m)
return m?3:1},
eo(a,b,c){var s,r=this
r.a1(c?1:0,3)
r.dA()
r.aM=8
r.ag(b)
r.ag(A.ad(b,8))
s=(~b>>>0)+65536&65535
r.ag(s)
r.ag(A.ad(s,8))
s=r.ay
s===$&&A.c("_window")
r.iK(s,a,b)},
cJ(){var s,r,q,p,o,n,m,l,k,j,i,h=this,g="_windowSize",f=h.c
do{s=h.ch
s===$&&A.c("_actualWindowSize")
r=h.k3
r===$&&A.c("_lookAhead")
q=h.k1
q===$&&A.c("_strStart")
p=s-r-q
if(p===0&&q===0&&r===0){s=h.as
s===$&&A.c(g)
p=s}else{s=h.as
s===$&&A.c(g)
if(q>=s+s-262){r=h.ay
r===$&&A.c("_window")
B.e.U(r,0,s,r,s)
s=h.k2
o=h.as
h.k2=s-o
h.k1=h.k1-o
s=h.fx
s===$&&A.c("_blockStart")
h.fx=s-o
s=h.db
s===$&&A.c("_hashSize")
r=h.cx
r===$&&A.c("_head")
q=r.length
n=s
m=n
do{--n
if(!(n>=0&&n<q))return A.a(r,n)
l=r[n]&65535
r[n]=l>=o?l-o:0}while(--m,m!==0)
s=h.CW
s===$&&A.c("_prev")
r=s.length
n=o
m=n
do{--n
if(!(n>=0&&n<r))return A.a(s,n)
l=s[n]&65535
s[n]=l>=o?l-o:0}while(--m,m!==0)
p+=o}}if(f.gbK())return
s=h.ay
s===$&&A.c("_window")
m=h.iN(s,h.k1+h.k3,p)
s=h.k3=h.k3+m
if(s>=3){r=h.ay
q=h.k1
k=r.length
if(q>>>0!==q||q>=k)return A.a(r,q)
j=r[q]&255
h.cy=j
i=h.fr
i===$&&A.c("_hashShift")
i=B.a.D(j,i);++q
if(!(q<k))return A.a(r,q)
q=r[q]
r=h.dy
r===$&&A.c("_hashMask")
h.cy=((i^q&255)&r)>>>0}}while(s<262&&!f.gbK())},
hE(a){var s,r,q,p,o,n,m,l,k,j,i=this,h="_insertHash",g="_hashShift",f="_window",e="_strStart",d="_hashMask",c="_windowMask"
for(s=a===0,r=0;!0;){q=i.k3
q===$&&A.c("_lookAhead")
if(q<262){i.cJ()
q=i.k3
if(q<262&&s)return 0
if(q===0)break}if(q>=3){q=i.cy
q===$&&A.c(h)
p=i.fr
p===$&&A.c(g)
p=B.a.D(q,p)
q=i.ay
q===$&&A.c(f)
o=i.k1
o===$&&A.c(e)
n=o+2
if(!(n>=0&&n<q.length))return A.a(q,n)
n=q[n]
q=i.dy
q===$&&A.c(d)
q=((p^n&255)&q)>>>0
i.cy=q
n=i.cx
n===$&&A.c("_head")
if(!(q<n.length))return A.a(n,q)
p=n[q]
r=p&65535
m=i.CW
m===$&&A.c("_prev")
l=i.ax
l===$&&A.c(c)
l=(o&l)>>>0
if(!(l>=0&&l<m.length))return A.a(m,l)
m[l]=p
n[q]=o}if(r!==0){q=i.k1
q===$&&A.c(e)
p=i.as
p===$&&A.c("_windowSize")
p=(q-r&65535)<=p-262
q=p}else q=!1
if(q){q=i.p1
q===$&&A.c("_strategy")
if(q!==2)i.fy=i.e3(r)}q=i.fy
q===$&&A.c("_matchLength")
p=i.k1
if(q>=3){p===$&&A.c(e)
k=i.bC(p-i.k2,q-3)
q=i.k3
p=i.fy
q-=p
i.k3=q
o=$.ao.b
if(o==null?$.ao==null:o===$.ao)A.F(A.hx($.ao.a))
if(p<=o.b&&q>=3){q=i.fy=p-1
do{p=i.k1=i.k1+1
o=i.cy
o===$&&A.c(h)
n=i.fr
n===$&&A.c(g)
n=B.a.D(o,n)
o=i.ay
o===$&&A.c(f)
m=p+2
if(!(m>=0&&m<o.length))return A.a(o,m)
m=o[m]
o=i.dy
o===$&&A.c(d)
o=((n^m&255)&o)>>>0
i.cy=o
m=i.cx
m===$&&A.c("_head")
if(!(o<m.length))return A.a(m,o)
n=m[o]
r=n&65535
l=i.CW
l===$&&A.c("_prev")
j=i.ax
j===$&&A.c(c)
j=(p&j)>>>0
if(!(j>=0&&j<l.length))return A.a(l,j)
l[j]=n
m[o]=p}while(q=i.fy=q-1,q!==0)
i.k1=p+1}else{q=i.k1=i.k1+p
i.fy=0
p=i.ay
p===$&&A.c(f)
o=p.length
if(!(q>=0&&q<o))return A.a(p,q)
n=p[q]&255
i.cy=n
m=i.fr
m===$&&A.c(g)
m=B.a.D(n,m);++q
if(!(q<o))return A.a(p,q)
q=p[q]
p=i.dy
p===$&&A.c(d)
i.cy=((m^q&255)&p)>>>0}}else{q=i.ay
q===$&&A.c(f)
p===$&&A.c(e)
if(!(p>=0&&p<q.length))return A.a(q,p)
k=i.bC(0,q[p]&255)
i.k3=i.k3-1
i.k1=i.k1+1}if(k)i.aV(!1)}s=a===4
i.aV(s)
return s?3:1},
hF(a0){var s,r,q,p,o,n,m,l,k,j,i,h=this,g="_insertHash",f="_hashShift",e="_window",d="_strStart",c="_hashMask",b="_windowMask",a="_matchAvailable"
for(s=a0===0,r=0;!0;){q=h.k3
q===$&&A.c("_lookAhead")
if(q<262){h.cJ()
q=h.k3
if(q<262&&s)return 0
if(q===0)break}if(q>=3){q=h.cy
q===$&&A.c(g)
p=h.fr
p===$&&A.c(f)
p=B.a.D(q,p)
q=h.ay
q===$&&A.c(e)
o=h.k1
o===$&&A.c(d)
n=o+2
if(!(n>=0&&n<q.length))return A.a(q,n)
n=q[n]
q=h.dy
q===$&&A.c(c)
q=((p^n&255)&q)>>>0
h.cy=q
n=h.cx
n===$&&A.c("_head")
if(!(q<n.length))return A.a(n,q)
p=n[q]
r=p&65535
m=h.CW
m===$&&A.c("_prev")
l=h.ax
l===$&&A.c(b)
l=(o&l)>>>0
if(!(l>=0&&l<m.length))return A.a(m,l)
m[l]=p
n[q]=o}q=h.fy
q===$&&A.c("_matchLength")
h.k4=q
h.go=h.k2
h.fy=2
if(r!==0){p=$.ao.b
if(p==null?$.ao==null:p===$.ao)A.F(A.hx($.ao.a))
if(q<p.b){q=h.k1
q===$&&A.c(d)
p=h.as
p===$&&A.c("_windowSize")
p=(q-r&65535)<=p-262
q=p}else q=!1}else q=!1
if(q){q=h.p1
q===$&&A.c("_strategy")
if(q!==2){q=h.e3(r)
h.fy=q}else q=2
if(q<=5)if(h.p1!==1)if(q===3){p=h.k1
p===$&&A.c(d)
p=p-h.k2>4096}else p=!1
else p=!0
else p=!1
if(p){h.fy=2
q=2}}else q=2
p=h.k4
if(p>=3&&q<=p){q=h.k1
q===$&&A.c(d)
k=q+h.k3-3
j=h.bC(q-1-h.go,p-3)
p=h.k3
q=h.k4
h.k3=p-(q-1)
q=h.k4=q-2
do{p=h.k1=h.k1+1
if(p<=k){o=h.cy
o===$&&A.c(g)
n=h.fr
n===$&&A.c(f)
n=B.a.D(o,n)
o=h.ay
o===$&&A.c(e)
m=p+2
if(!(m>=0&&m<o.length))return A.a(o,m)
m=o[m]
o=h.dy
o===$&&A.c(c)
o=((n^m&255)&o)>>>0
h.cy=o
m=h.cx
m===$&&A.c("_head")
if(!(o<m.length))return A.a(m,o)
n=m[o]
r=n&65535
l=h.CW
l===$&&A.c("_prev")
i=h.ax
i===$&&A.c(b)
i=(p&i)>>>0
if(!(i>=0&&i<l.length))return A.a(l,i)
l[i]=n
m[o]=p}}while(q=h.k4=q-1,q!==0)
h.id=0
h.fy=2
h.k1=p+1
if(j)h.aV(!1)}else{q=h.id
q===$&&A.c(a)
if(q!==0){q=h.ay
q===$&&A.c(e)
p=h.k1
p===$&&A.c(d);--p
if(!(p>=0&&p<q.length))return A.a(q,p)
if(h.bC(0,q[p]&255))h.aV(!1)
h.k1=h.k1+1
h.k3=h.k3-1}else{h.id=1
q=h.k1
q===$&&A.c(d)
h.k1=q+1
h.k3=h.k3-1}}}s=h.id
s===$&&A.c(a)
if(s!==0){s=h.ay
s===$&&A.c(e)
q=h.k1
q===$&&A.c(d);--q
if(!(q>=0&&q<s.length))return A.a(s,q)
h.bC(0,s[q]&255)
h.id=0}s=a0===4
h.aV(s)
return s?3:1},
e3(a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=this,b=$.ao.bA().d,a=c.k1
a===$&&A.c("_strStart")
s=c.k4
s===$&&A.c("_prevLength")
r=c.as
r===$&&A.c("_windowSize")
r-=262
q=a>r?a-r:0
p=$.ao.bA().c
r=c.ax
r===$&&A.c("_windowMask")
o=c.k1+258
n=c.ay
n===$&&A.c("_window")
m=a+s
l=m-1
k=n.length
if(!(l>=0&&l<k))return A.a(n,l)
j=n[l]
if(!(m>=0&&m<k))return A.a(n,m)
i=n[m]
if(c.k4>=$.ao.bA().a)b=b>>>2
n=c.k3
n===$&&A.c("_lookAhead")
if(p>n)p=n
h=o-258
g=s
f=a
do{c$0:{a=c.ay
s=a0+g
n=a.length
if(!(s>=0&&s<n))return A.a(a,s)
if(a[s]===i){--s
if(!(s>=0))return A.a(a,s)
if(a[s]===j){if(!(a0>=0&&a0<n))return A.a(a,a0)
s=a[a0]
if(!(f>=0&&f<n))return A.a(a,f)
if(s===a[f]){e=a0+1
if(!(e<n))return A.a(a,e)
s=a[e]
m=f+1
if(!(m<n))return A.a(a,m)
m=s!==a[m]
s=m}else{e=a0
s=!0}}else{e=a0
s=!0}}else{e=a0
s=!0}if(s)break c$0
f+=2;++e
do{++f
if(!(f>=0&&f<n))return A.a(a,f)
s=a[f];++e
if(!(e>=0&&e<n))return A.a(a,e)
if(s===a[e]){++f
if(!(f<n))return A.a(a,f)
s=a[f];++e
if(!(e<n))return A.a(a,e)
if(s===a[e]){++f
if(!(f<n))return A.a(a,f)
s=a[f];++e
if(!(e<n))return A.a(a,e)
if(s===a[e]){++f
if(!(f<n))return A.a(a,f)
s=a[f];++e
if(!(e<n))return A.a(a,e)
if(s===a[e]){++f
if(!(f<n))return A.a(a,f)
s=a[f];++e
if(!(e<n))return A.a(a,e)
if(s===a[e]){++f
if(!(f<n))return A.a(a,f)
s=a[f];++e
if(!(e<n))return A.a(a,e)
if(s===a[e]){++f
if(!(f<n))return A.a(a,f)
s=a[f];++e
if(!(e<n))return A.a(a,e)
if(s===a[e]){++f
if(!(f<n))return A.a(a,f)
s=a[f];++e
if(!(e<n))return A.a(a,e)
s=s===a[e]&&f<o}else s=!1}else s=!1}else s=!1}else s=!1}else s=!1}else s=!1}else s=!1}while(s)
d=258-(o-f)
if(d>g){c.k2=a0
if(d>=p){g=d
break}a=c.ay
s=h+d
n=s-1
m=a.length
if(!(n>=0&&n<m))return A.a(a,n)
j=a[n]
if(!(s<m))return A.a(a,s)
i=a[s]
g=d}f=h}a=c.CW
a===$&&A.c("_prev")
s=a0&r
if(!(s>=0&&s<a.length))return A.a(a,s)
a0=a[s]&65535
if(a0>q){--b
a=b!==0}else a=!1}while(a)
a=c.k3
if(g<=a)return g
return a},
iN(a,b,c){var s,r,q,p,o=this
if(c===0||o.c.gbK())return 0
s=o.c.a_(c)
r=s.gv(s)
if(r===0)return 0
q=s.S()
p=q.length
if(r>p)r=p
B.e.az(a,b,b+r,q)
o.b+=r
o.a=A.at(q,o.a)
return r},
c6(){var s,r=this,q=r.x
q===$&&A.c("_pending")
s=r.f
s===$&&A.c("_pendingBuffer")
r.d.bT(s,q)
s=r.w
s===$&&A.c("_pendingOut")
r.w=s+q
q=r.x-q
r.x=q
if(q===0)r.w=0},
i_(a){switch(a){case 0:return new A.as(0,0,0,0,0)
case 1:return new A.as(4,4,8,4,1)
case 2:return new A.as(4,5,16,8,1)
case 3:return new A.as(4,6,32,32,1)
case 4:return new A.as(4,4,16,16,2)
case 5:return new A.as(8,16,32,32,2)
case 6:return new A.as(8,16,128,128,2)
case 7:return new A.as(8,32,128,256,2)
case 8:return new A.as(32,128,258,1024,2)
case 9:return new A.as(32,258,258,4096,2)}throw A.d(A.cp("Invalid Deflate parameter"))}}
A.as.prototype={}
A.j4.prototype={
hX(a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1=this,a2="_optimalLen",a3=a1.a
a3===$&&A.c("dynamicTree")
s=a1.c
s===$&&A.c("staticDesc")
r=s.a
q=s.b
p=s.c
o=s.e
for(s=a4.ry,n=0;n<=15;++n)s[n]=0
m=a4.to
l=a4.x2
l===$&&A.c("_heapMax")
if(!(l>=0&&l<573))return A.a(m,l)
k=m[l]*2+1
j=a3.length
if(!(k>=0&&k<j))return A.a(a3,k)
a3[k]=0
for(i=l+1,l=r!=null,k=q.length,h=0;i<573;++i){g=m[i]
f=g*2
e=f+1
if(!(e>=0&&e<j))return A.a(a3,e)
d=a3[e]*2+1
if(!(d>=0&&d<j))return A.a(a3,d)
n=a3[d]+1
if(n>o){++h
n=o}a3[e]=n
d=a1.b
d===$&&A.c("maxCode")
if(g>d)continue
if(!(n>=0&&n<16))return A.a(s,n)
s[n]=s[n]+1
if(g>=p){d=g-p
if(!(d>=0&&d<k))return A.a(q,d)
c=q[d]}else c=0
if(!(f>=0&&f<j))return A.a(a3,f)
b=a3[f]
f=a4.ab
f===$&&A.c(a2)
a4.ab=f+b*(n+c)
if(l){f=a4.aL
f===$&&A.c("_staticLen")
if(!(e<r.length))return A.a(r,e)
a4.aL=f+b*(r[e]+c)}}if(h===0)return
n=o-1
do{a=n
while(!0){if(!(a>=0&&a<16))return A.a(s,a)
l=s[a]
if(!(l===0))break;--a}s[a]=l-1
l=a+1
if(!(l<16))return A.a(s,l)
s[l]=s[l]+2
if(!(o<16))return A.a(s,o)
s[o]=s[o]-1
h-=2}while(h>0)
for(n=o;n!==0;--n){if(!(n>=0))return A.a(s,n)
g=s[n]
for(;g!==0;){--i
if(!(i>=0&&i<573))return A.a(m,i)
a0=m[i]
l=a1.b
l===$&&A.c("maxCode")
if(a0>l)continue
l=a0*2
k=l+1
if(!(k>=0&&k<j))return A.a(a3,k)
f=a3[k]
if(f!==n){e=a4.ab
e===$&&A.c(a2)
if(!(l>=0&&l<j))return A.a(a3,l)
a4.ab=e+(n-f)*a3[l]
a3[k]=n}--g}}},
cv(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=this,c=d.a
c===$&&A.c("dynamicTree")
s=d.c
s===$&&A.c("staticDesc")
r=s.a
q=s.d
a.x1=0
a.x2=573
for(s=c.length,p=a.to,o=a.xr,n=0,m=-1;n<q;++n){l=n*2
if(!(l<s))return A.a(c,l)
if(c[l]!==0){l=++a.x1
if(!(l>=0&&l<573))return A.a(p,l)
p[l]=n
if(!(n<573))return A.a(o,n)
o[n]=0
m=n}else{++l
if(!(l<s))return A.a(c,l)
c[l]=0}}for(l=r!=null;k=a.x1,k<2;){++k
a.x1=k
if(m<2){++m
j=m}else j=0
if(!(k>=0))return A.a(p,k)
p[k]=j
k=j*2
if(!(k>=0&&k<s))return A.a(c,k)
c[k]=1
o[j]=0
i=a.ab
i===$&&A.c("_optimalLen")
a.ab=i-1
if(l){i=a.aL
i===$&&A.c("_staticLen");++k
if(!(k<r.length))return A.a(r,k)
a.aL=i-r[k]}}d.b=m
for(n=B.a.F(k,2);n>=1;--n)a.cU(c,n)
j=q
do{n=p[1]
l=a.x1--
if(!(l>=0&&l<573))return A.a(p,l)
p[1]=p[l]
a.cU(c,1)
h=p[1]
l=--a.x2
if(!(l>=0&&l<573))return A.a(p,l)
p[l]=n;--l
a.x2=l
if(!(l>=0))return A.a(p,l)
p[l]=h
l=j*2
k=n*2
if(!(k>=0&&k<s))return A.a(c,k)
i=c[k]
g=h*2
if(!(g>=0&&g<s))return A.a(c,g)
f=c[g]
if(!(l<s))return A.a(c,l)
c[l]=i+f
if(!(n>=0&&n<573))return A.a(o,n)
f=o[n]
if(!(h>=0&&h<573))return A.a(o,h)
i=o[h]
l=f>i?f:i
if(!(j<573))return A.a(o,j)
o[j]=l+1;++k;++g
if(!(g<s))return A.a(c,g)
c[g]=j
if(!(k<s))return A.a(c,k)
c[k]=j
e=j+1
p[1]=j
a.cU(c,1)
if(a.x1>=2){j=e
continue}else break}while(!0)
s=--a.x2
o=p[1]
if(!(s>=0&&s<573))return A.a(p,s)
p[s]=o
d.hX(a)
A.oU(c,m,a.ry)}}
A.ft.prototype={}
A.ha.prototype={
fA(a){var s,r,q,p,o,n,m,l,k,j,i,h=this,g=a.length
for(s=0;s<g;++s){if(!(s<a.length))return A.a(a,s)
r=a[s]
q=h.b
if(typeof r!=="number")return r.kM()
if(r>q)h.sk7(r)
if(!(s<a.length))return A.a(a,s)
r=a[s]
q=h.c
if(typeof r!=="number")return r.dd()
if(r<q)h.skb(r)}p=B.a.D(1,h.b)
h.a=new Uint32Array(p)
for(o=1,n=0,m=2;o<=h.b;){for(r=o<<16,s=0;s<g;++s){if(!(s<a.length))return A.a(a,s)
if(J.au(a[s],o)){for(l=n,k=0,j=0;j<o;++j){k=(k<<1|l&1)>>>0
l=l>>>1}for(q=h.a,i=(r|s)>>>0,j=k;j<p;j+=m){if(!(j>=0&&j<q.length))return A.a(q,j)
q[j]=i}++n}}++o
n=n<<1>>>0
m=m<<1>>>0}},
sk7(a){this.b=A.o(a)},
skb(a){this.c=A.o(a)}}
A.ed.prototype={
dY(){var s,r,q,p,o=this
o.e=o.d=0
if(!o.b)return
s=o.a
s===$&&A.c("input")
r=s.c
while(!0){q=s.b
p=s.e
p===$&&A.c("_length")
if(!(q<r+p))break
if(!o.is())break}},
is(){var s,r=this,q=r.a
q===$&&A.c("input")
if(q.gbK())return!1
s=r.ah(3)
switch(B.a.i(s,1)){case 0:if(r.iC()===-1)return!1
break
case 1:if(r.dK(r.r,r.w)===-1)return!1
break
case 2:if(r.it()===-1)return!1
break
default:return!1}return(s&1)===0},
ah(a){var s,r,q,p,o=this
if(a===0)return 0
for(s=o.a;r=o.e,r<a;){s===$&&A.c("input")
q=s.b
p=s.e
p===$&&A.c("_length")
if(q>=s.c+p)return-1
p=s.a
s.b=q+1
if(!(q>=0&&q<p.length))return A.a(p,q)
q=p[q]
o.d=(o.d|B.a.D(q,r))>>>0
o.e=r+8}s=o.d
q=B.a.B(1,a)
o.d=B.a.L(s,a)
o.e=r-a
return(s&q-1)>>>0},
cW(a){var s,r,q,p,o,n,m,l=this,k=a.a
k===$&&A.c("table")
s=a.b
for(r=l.a;q=l.e,q<s;){r===$&&A.c("input")
p=r.b
o=r.e
o===$&&A.c("_length")
if(p>=r.c+o)return-1
o=r.a
r.b=p+1
if(!(p>=0&&p<o.length))return A.a(o,p)
p=o[p]
l.d=(l.d|B.a.D(p,q))>>>0
l.e=q+8}r=l.d
p=(r&B.a.D(1,s)-1)>>>0
if(!(p<k.length))return A.a(k,p)
n=k[p]
m=n>>>16
l.d=B.a.L(r,m)
l.e=q-m
return n&65535},
iC(){var s,r,q=this
q.e=q.d=0
s=q.ah(16)
r=q.ah(16)
if(s!==0&&s!==(r^65535)>>>0)return-1
r=q.a
r===$&&A.c("input")
if(s>r.gv(r))return-1
q.c.kJ(r.a_(s))
return 0},
it(){var s,r,q,p,o,n,m,l,k,j,i=this,h=i.ah(5)
if(h===-1)return-1
h+=257
if(h>288)return-1
s=i.ah(5)
if(s===-1)return-1;++s
if(s>32)return-1
r=i.ah(4)
if(r===-1)return-1
r+=4
if(r>19)return-1
q=new Uint8Array(19)
for(p=0;p<r;++p){o=i.ah(3)
if(o===-1)return-1
n=B.M[p]
if(!(n<19))return A.a(q,n)
q[n]=o}m=A.c1(q)
n=h+s
l=new Uint8Array(n)
k=A.z(l.buffer,0,h)
j=A.z(l.buffer,h,s)
if(i.hj(n,m,l)===-1)return-1
return i.dK(A.c1(k),A.c1(j))},
dK(a,b){var s,r,q,p,o,n,m,l=this
for(s=l.c;!0;){r=l.cW(a)
if(r<0||r>285)return-1
if(r===256)break
if(r<256){s.n(r&255)
continue}q=r-257
if(!(q>=0&&q<29))return A.a(B.aD,q)
p=B.aD[q]+l.ah(B.ds[q])
o=l.cW(b)
if(o<0||o>29)return-1
if(!(o>=0&&o<30))return A.a(B.ax,o)
n=B.ax[o]+l.ah(B.w[o])
for(m=-n;p>n;){s.T(s.R(m))
p-=n}if(p===n)s.T(s.R(m))
else s.T(s.dj(m,p-n))}for(s=l.a;m=l.e,m>=8;){l.e=m-8
s===$&&A.c("input")
if(--s.b<0)s.b=0}return 0},
hj(a,b,c){var s,r,q,p,o,n,m,l=this
t.L.a(c)
for(s=c.length,r=0,q=0;q<a;){p=l.cW(b)
if(p===-1)return-1
switch(p){case 16:o=l.ah(2)
if(o===-1)return-1
o+=3
for(;n=o-1,o>0;o=n,q=m){m=q+1
if(!(q>=0&&q<s))return A.a(c,q)
c[q]=r}break
case 17:o=l.ah(3)
if(o===-1)return-1
o+=3
for(;n=o-1,o>0;o=n,q=m){m=q+1
if(!(q>=0&&q<s))return A.a(c,q)
c[q]=0}r=0
break
case 18:o=l.ah(7)
if(o===-1)return-1
o+=11
for(;n=o-1,o>0;o=n,q=m){m=q+1
if(!(q>=0&&q<s))return A.a(c,q)
c[q]=0}r=0
break
default:if(p<0||p>15)return-1
m=q+1
if(!(q>=0&&q<s))return A.a(c,q)
c[q]=p
q=m
r=p
break}}return 0}}
A.iD.prototype={}
A.iC.prototype={}
A.iE.prototype={
eH(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g=t.L
g.a(a)
s=A.hJ(1,32768)
s.n(120)
for(r=0;q=(r|0)>>>0,(30720+q)%31!==0;)++r
s.n(q)
p=A.q_(a)
o=A.bB(a,1,null,0)
q=A.kk()
n=A.kk()
m=A.kk()
l=new Uint16Array(16)
k=new Uint32Array(573)
j=new Uint8Array(573)
i=A.hJ(0,32768)
l=new A.fY(o,i,q,n,m,l,k,j)
if(b==null||b===-1)b=6
if(typeof b!=="number")return b.dd()
if(b<=9)k=!1
else k=!0
if(k)A.F(A.cp("Invalid Deflate parameter"))
$.ao.b=l.i_(b)
k=new Uint16Array(1146)
l.p2=k
j=new Uint16Array(122)
l.p3=j
h=new Uint16Array(78)
l.p4=h
l.at=15
l.as=32768
l.ax=32767
l.dx=15
l.db=32768
l.dy=32767
l.fr=5
l.ay=new Uint8Array(65536)
l.CW=new Uint16Array(32768)
l.cx=new Uint16Array(32768)
l.y2=16384
l.f=new Uint8Array(65536)
l.r=65536
l.au=16384
l.y1=49152
l.ok=A.o(b)
l.w=l.x=l.p1=0
l.e=113
l.a=0
q.a=k
k=t.aK
q.c=k.a($.mT())
n.a=j
n.c=k.a($.mS())
m.a=h
m.c=k.a($.mR())
l.aj=l.ae=0
l.aM=8
l.dZ()
l.ik()
l.hD(4)
l.c6()
s.T(g.a(A.z(i.c.buffer,0,i.a)))
s.P(p)
g=A.z(s.c.buffer,0,s.a)
return g},
jO(a){return this.eH(a,null)}}
A.jJ.prototype={
$1(a){return new A.c4()},
$S:22}
A.c4.prototype={
c4(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=null
switch(A.q4(b)){case B.hS:s=new Uint8Array(64)
r=new Uint8Array(64)
q=new Float32Array(64)
p=new Float32Array(64)
o=A.H(65535,d,!1,t.T)
n=t.x
m=A.H(65535,d,!1,n)
l=A.H(64,d,!1,n)
n=A.H(64,d,!1,n)
k=new Float32Array(64)
j=new Float32Array(64)
i=new Float32Array(64)
s=new A.ht(s,r,q,p,o,m,l,n,k,j,i,new Int32Array(2048))
s.sfJ(s.c0(B.ah,B.G))
s.sfH(s.c0(B.ai,B.G))
r=t.w
s.sfQ(r.a(s.c0(B.aj,B.al)))
s.sfP(r.a(s.c0(B.ak,B.af)))
s.i6()
s.i9()
s.fc(100)
h=new Uint8Array(A.b_(s.b7(a)))
g=$.co().bn("jpg",d)
break
case B.aN:case B.hP:case B.hV:case B.hW:case B.hU:case B.hT:h=new Uint8Array(A.b_(A.lk(6).b7(a)))
g=$.co().bn("png",d)
break
case B.hQ:s=new A.h6(10)
s.ci(a)
s=s.cm()
s.toString
h=new Uint8Array(A.b_(s))
g=$.co().bn("gif",d)
break
case B.hO:h=new Uint8Array(A.b_(new A.fU().b7(a)))
g=$.co().bn("bmp",d)
break
case B.aN:h=new Uint8Array(A.b_(new A.i0().b7(a)))
g=$.co().bn("tga",d)
break
case B.hR:h=new Uint8Array(A.b_(new A.hd().jQ(A.b([a],t.jI))))
g=$.co().bn("ico",d)
break
default:h=d
g=h}if(h!=null){s=g==null?"":g
r=h.length
q=t.N
q=A.cR(["size",""+r,"c","d"],q,q)
f=new A.bh("")
e=A.b([-1],t.t)
A.o0(s,d,q,f,e)
B.b.A(e,f.a.length)
s=f.a+=";base64,"
B.b.A(e,s.length-1)
s=B.aP.fg(new A.dB(f,t.nn))
t.L.a(h)
A.ab(0,r,r)
s.h2(h,0,r,!0)
s=f.a
return new A.i8(s.charCodeAt(0)==0?s:s,e).u(0)}return d},
f8(a){var s,r=A.jB(a)
if(r==null)return null
s=r.a6(a)
if(s!=null)return this.c4(A.q6(s),r)
return null},
jF(a,b,c,d,e){var s,r=A.jB(a)
if(r==null)return null
s=r.a6(a)
if(s!=null)return this.c4(A.pX(s,b,c,d,e),r)
return null},
jU(a,b){var s,r=A.jB(a)
if(r==null)return null
s=r.a6(a)
if(s!=null)return this.c4(b==="vertical"?A.mr(s):A.dN(s),r)
return null},
kv(a,b,c){var s,r=A.jB(a)
if(r==null)return null
s=r.a6(a)
if(s!=null)return this.c4(A.pY(s,c,b),r)
return null},
gkd(){var s,r=this,q=r.a
if(q===$){s=A.cR([1,new A.hh(r),2,new A.hi(r),3,new A.hj(r),4,new A.hk(r)],t.p,t.g9)
r.a!==$&&A.mz("operations")
r.sfM(s)
q=s}return q},
sfM(a){this.a=t.cG.a(a)},
$ilQ:1}
A.hh.prototype={
$1(a){return this.a.f8(t.D.a(J.kI(t.A.a(a).e,0)))},
$S:3}
A.hi.prototype={
$1(a){var s=t.A.a(a).e,r=J.ae(s)
return this.a.jF(t.D.a(r.q(s,0)),A.o(r.q(s,1)),A.o(r.q(s,2)),A.o(r.q(s,3)),A.o(r.q(s,4)))},
$S:3}
A.hj.prototype={
$1(a){var s=t.A.a(a).e,r=J.ae(s)
return this.a.jU(t.D.a(r.q(s,0)),A.a_(r.q(s,1)))},
$S:3}
A.hk.prototype={
$1(a){var s=t.A.a(a).e,r=J.ae(s)
return this.a.kv(t.D.a(r.q(s,0)),A.o(r.q(s,1)),A.o(r.q(s,2)))},
$S:3}
A.bZ.prototype={
fs(a){var s,r,q,p
if(a!=null&&a.a!=null){s=a.a.length
r=J.nC(s,t.D)
for(q=0;q<s;++q){p=a.a
if(!(q<p.length))return A.a(p,q)
p=p[q]
r[q]=new Uint8Array(p.subarray(0,A.aD(0,null,p.length)))}this.seS(r)}},
seS(a){this.a=t.jj.a(a)}}
A.cs.prototype={
u(a){return"BitmapCompression."+this.b}}
A.fQ.prototype={
eZ(){var s,r=this.b
r===$&&A.c("offset")
s=this.a
s===$&&A.c("fileLength")
return A.cR(["offset",r,"fileLength",s,"fileType",19778],t.N,t.p)}}
A.b6.prototype={
gco(){var s=this.r
if(s!==40)s=s===124&&this.cx===0
else s=!0
return s},
gb9(a){return Math.abs(this.e)},
dm(a,b){var s=this
if(B.b.aB(A.b([1,4,8],t.t),s.x))s.kn(a)
if(s.r===124){s.ay=a.j()
s.ch=a.j()
s.CW=a.j()
s.cx=a.j()}},
kn(a){var s=this,r=s.at
if(r===0)r=B.a.B(1,s.x)
s.sjy(A.l7(r,new A.fV(s,a,s.r===12?3:4),t.p).aP(0))},
cX(a,b){var s,r,q,p
if(!B.a.gbL(this.e)){s=a.t()
r=a.t()
q=a.t()
p=b==null?a.t():b
return A.aE(q,r,s,this.gco()?255:p)}else{q=a.t()
s=a.t()
r=a.t()
p=b==null?a.t():b
return A.aE(q,s,r,this.gco()?255:p)}},
eg(a){return this.cX(a,null)},
jL(a,b){var s,r,q,p,o,n=this
t.lt.a(b)
if(n.cy!=null){s=n.x
if(s===4){r=a.t()
q=B.a.i(r,4)
p=r&15
s=n.cy
if(!(q<s.length))return A.a(s,q)
b.$1(s[q])
s=n.cy
if(!(p<s.length))return A.a(s,p)
b.$1(s[p])
return}else if(s===8){r=a.t()
s=n.cy
if(!(r>=0&&r<s.length))return A.a(s,r)
b.$1(s[r])
return}}s=n.y
if(s===B.N&&n.x===32)return b.$1(n.eg(a))
else{o=n.x
if(o===32&&s===B.O)return b.$1(n.eg(a))
else if(o===24)return b.$1(n.cX(a,255))
else throw A.d(A.f("Unsupported bpp ("+o+") or compression ("+s.u(0)+")."))}},
he(){switch(this.y.a){case 0:return"BI_BITFIELDS"
case 1:return"none"}},
u(a){var s=this
return A.lW(A.cR(["headerSize",s.r,"width",s.f,"height",s.gb9(s),"planes",s.w,"bpp",s.x,"file",s.d.eZ(),"compression",s.he(),"imageSize",s.z,"xppm",s.Q,"yppm",s.as,"totalColors",s.at,"importantColors",s.ax,"readBottomUp",!B.a.gbL(s.e),"v5redMask",A.jz(s.ay),"v5greenMask",A.jz(s.ch),"v5blueMask",A.jz(s.CW),"v5alphaMask",A.jz(s.cx)],t.N,t.K),null," ")},
sjy(a){this.cy=t.T.a(a)}}
A.fV.prototype={
$1(a){var s
A.o(a)
s=this.c===3?100:null
return this.a.cX(this.b,s)},
$S:19}
A.bT.prototype={
aH(a){var s,r=null
t.L.a(a)
if(!A.fR(A.l(a,!1,r,0)))return r
s=A.l(a,!1,r,0)
this.a=s
return this.b=A.n5(s,r)},
a4(a){var s,r,q,p,o,n,m,l,k,j,i=this,h=i.a
h===$&&A.c("_input")
s=i.b
r=s.d.b
r===$&&A.c("offset")
h.d=r
r=s.f
q=B.a.i(r*s.x,3)
h=B.a.I(q,4)
if(h!==0)q+=4-h
p=A.T(r,s.gb9(s),B.f,null,null)
for(o=p.b-1,h=p.a,n=o;n>=0;--n){s=i.b.e
m=!(s===0?1/s<0:s<0)?n:o-n
s=i.a
l=s.R(q)
s.d=s.d+(l.c-l.d)
k={}
for(k.a=0;k.a<h;j={},j.a=k.a,k=j)i.b.jL(l,new A.fT(k,p,m))}return p},
a6(a){t.L.a(a)
if(!A.fR(A.l(a,!1,null,0)))return null
this.aH(a)
return this.a4(0)}}
A.fT.prototype={
$1(a){return this.b.fb(this.a.a++,this.c,a)},
$S:11}
A.e_.prototype={}
A.fU.prototype={
b7(a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=A.aq(!1,8192),d=a0.c===B.o?3:4,c=a0.a,b=a0.b,a=c*b*d
e.M(19778)
e.P(a+54)
e.P(0)
e.P(54)
e.P(40)
e.P(c)
e.P(-b)
e.M(1)
e.M(d*8)
e.P(0)
e.P(a)
e.P(0)
e.P(0)
e.P(0)
e.P(0)
for(s=d===4,r=!s,q=a0.x,p=q.length,o=c*d,n=t.t,m=0,l=0;m<b;++m){for(k=0;k<c;++k,++l){if(!(l>=0&&l<p))return A.a(q,l)
j=q[l]
e.n(j>>>16&255)
e.n(j>>>8&255)
e.n(j&255)
if(s)e.n(j>>>24&255)}if(r){i=4-B.a.I(o,4)
if(i!==4){h=i-1
g=A.b(new Array(h),n)
for(f=0;f<h;++f)g[f]=0
e.T(g)
e.n(255)}}}return A.z(e.c.buffer,0,e.a)}}
A.fX.prototype={}
A.a9.prototype={}
A.h0.prototype={}
A.e2.prototype={}
A.cH.prototype={
bM(){return this.r},
ao(a,b,c,d,e){throw A.d(A.f("B44 compression not yet supported."))},
bp(a,b,c){return this.ao(a,b,c,null,null)}}
A.e3.prototype={
gkF(a){var s=this.b
s===$&&A.c("type")
return s},
ft(a){var s=this,r=a.bO()
s.a=r
if(r.length===0){s.a=null
return}s.b=a.j()
a.t()
a.d+=3
s.e=a.j()
s.f=a.j()
switch(s.b){case 0:s.c=4
break
case 1:s.c=2
break
case 2:s.c=4
break
default:throw A.d(A.f("EXR Invalid pixel type: "+s.gkF(s)))}}}
A.aO.prototype={
ao(a,b,c,d,e){throw A.d(A.f("Unsupported compression type"))},
bp(a,b,c){return this.ao(a,b,c,null,null)}}
A.eh.prototype={}
A.e4.prototype={
seP(a){this.c=t.T.a(a)}}
A.h1.prototype={
fu(a){var s,r,q,p,o=this,n=A.l(a,!1,null,0)
if(n.j()!==20000630)throw A.d(A.f("File is not an OpenEXR image file."))
s=o.e=n.t()
if(s!==2)throw A.d(A.f("Cannot read version "+s+" image files."))
s=o.f=n.an()
if((s&4294967289)>>>0!==0)throw A.d(A.f("The file format version number's flag field contains unrecognized flags."))
if((s&16)===0){r=A.l5((s&2)!==0,n)
if(r.f!=null)B.b.A(o.d,r)}else for(s=o.d;!0;){r=A.l5((o.f&2)!==0,n)
if(r.f==null)break
B.b.A(s,r)}s=o.d
q=s.length
if(q===0)throw A.d(A.f("Error reading image header"))
for(p=0;p<s.length;s.length===q||(0,A.b3)(s),++p)s[p].km(n)
o.iY(n)},
iY(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=this
for(s=f.d,r=0;r<s.length;++r){q=s[r]
p=q.a
for(o=q.b,n=p.a,m=0;m<o.length;++m){l=o[m]
if(!n.a3(l.a)){k=q.f
k.toString
f.a=k
j=q.r
j.toString
f.b=j
i=l.a
h=l.b
h===$&&A.c("type")
h=h===0?0:3
g=l.c
g===$&&A.c("size")
g=8*g
p.bF(new A.cF(i,k,j,h,g,A.l1(k*j,h,g)))}}if(q.cx)f.j6(r,a)
else f.j5(r,a)}},
j6(c0,c1){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3,b4,b5,b6,b7,b8=this,b9=b8.d
if(!(c0<b9.length))return A.a(b9,c0)
s=b9[c0]
b9=b8.f
b9===$&&A.c("flags")
r=(b9&16)!==0
q=s.ay
p=s.at
o=A.j(c1,null,0)
b9=s.b
n=s.a.a
m=0
l=0
while(!0){k=s.go
k.toString
if(!(m<k))break
j=0
while(!0){k=s.fy
k.toString
if(!(j<k))break
k=l!==0
i=0
h=0
while(!0){g=s.fx
if(!(m<g.length))return A.a(g,m)
if(!(i<g[m]))break
f=0
while(!0){g=s.fr
if(!(j<g.length))return A.a(g,j)
if(!(f<g[j]))break
if(k)break
if(!(l>=0&&l<p.length))return A.a(p,l)
g=p[l]
if(!(h>=0&&h<g.length))return A.a(g,h)
o.d=g[h]
if(r)if(o.j()!==c0)throw A.d(A.f("Invalid Image Data"))
e=o.j()
d=o.j()
o.j()
o.j()
c=o.R(o.j())
o.d=o.d+(c.c-c.d)
g=s.db
g.toString
b=d*g
a=s.cy
a.toString
q.toString
a0=b8.a
if(typeof a0!=="number")return A.D(a0)
a0=b8.b
if(typeof a0!=="number")return A.D(a0)
a1=q.ao(c,e*a,b,a,g)
a2=q.a
a3=q.b
a4=a1.length
a5=b9.length
a6=0
a7=0
while(!0){if(a7<a3){g=b8.b
if(typeof g!=="number")return A.D(g)
g=b<g}else g=!1
if(!g)break
for(a8=0;a8<a5;++a8){if(!(a8<b9.length))return A.a(b9,a8)
a9=b9[a8]
g=n.q(0,a9.a).f.buffer
b0=new Uint8Array(g,0)
if(a6>=a4)break
g=s.cy
g.toString
b1=e*g
for(g=a9.c,a=s.f,a0=s.r,b2=b0.length,b3=0;b3<a2;++b3,++b1){g===$&&A.c("size")
b4=0
for(;b4<g;++b4,a6=b6){a.toString
if(b1<a){a0.toString
b5=b<a0}else b5=!1
b6=a6+1
if(b5){b7=(b*a+b1)*g+b4
if(!(a6>=0&&a6<a4))return A.a(a1,a6)
b5=a1[a6]
if(!(b7>=0&&b7<b2))return A.a(b0,b7)
b0[b7]=b5}}}}++a7;++b}++f;++h}++i}++j;++l}++m}},
j5(b2,b3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1=this.d
if(!(b2<b1.length))return A.a(b1,b2)
s=b1[b2]
b1=this.f
b1===$&&A.c("flags")
r=(b1&16)!==0
q=s.ay
b1=s.at
if(0>=b1.length)return A.a(b1,0)
p=b1[0]
o=s.ch
b1=s.b
n=b1.length
m=new Uint32Array(n)
l=A.j(b3,null,0)
for(k=p.length,j=s.a.a,i=q!=null,h=0,g=0;g<k;++g){l.d=p[g]
if(r)if(l.j()!==b2)throw A.d(A.f("Invalid Image Data"))
f=l.j()
e=$.A()
e[0]=f
f=$.P()
if(0>=f.length)return A.a(f,0)
e[0]=l.j()
if(0>=f.length)return A.a(f,0)
d=l.R(f[0])
l.d=l.d+(d.c-d.d)
c=i?q.bp(d,0,h):d.S()
b=c.length
a=b1.length
o.toString
a0=0
while(!0){if(a0<o){f=this.b
if(typeof f!=="number")return A.D(f)
f=h<f}else f=!1
if(!f)break
f=s.CW
if(!(h>=0&&h<f.length))return A.a(f,h)
a1=f[h]
if(a1>=b)break
for(a2=0;a2<a;++a2){if(!(a2<b1.length))return A.a(b1,a2)
a3=b1[a2]
f=j.q(0,a3.a).f.buffer
a4=new Uint8Array(f,0)
if(a1>=b)break
f=s.f
f.toString
e=a3.c
a5=a4.length
a6=0
for(;a6<f;++a6){e===$&&A.c("size")
a7=0
for(;a7<e;++a7,a1=a9){if(!(a2<n))return A.a(m,a2)
a8=m[a2]
if(!(a2<n))return A.a(m,a2)
m[a2]=a8+1
a9=a1+1
if(!(a1>=0&&a1<b))return A.a(c,a1)
b0=c[a1]
if(!(a8<a5))return A.a(a4,a8)
a4[a8]=b0}}}++a0;++h}}}}
A.e5.prototype={
fv(b1,b2,b3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8=this,a9="dataWindow",b0="Unknown LevelMode format."
for(s=a8.c,r=t.t,q=t.L,p=a8.b;!0;){o=b2.bO()
if(o.length===0)break
b2.bO()
n=b2.R(b2.j())
b2.d=b2.d+(n.c-n.d)
s.h(0,o,new A.e2())
switch(o){case"channels":for(;!0;){m=new A.e3()
m.ft(n)
if(m.a==null)break
B.b.A(p,m)}break
case"chromaticities":l=new Float32Array(8)
a8.Q=l
k=n.j()
j=$.A()
j[0]=k
k=$.bt()
if(0>=k.length)return A.a(k,0)
l[0]=k[0]
l=a8.Q
j[0]=n.j()
l[1]=k[0]
l=a8.Q
j[0]=n.j()
l[2]=k[0]
l=a8.Q
j[0]=n.j()
l[3]=k[0]
l=a8.Q
j[0]=n.j()
l[4]=k[0]
l=a8.Q
j[0]=n.j()
l[5]=k[0]
l=a8.Q
j[0]=n.j()
l[6]=k[0]
l=a8.Q
j[0]=n.j()
l[7]=k[0]
break
case"compression":l=n.a
k=n.d++
if(!(k>=0&&k<l.length))return A.a(l,k)
k=l[k]
a8.as=k
if(k>7)throw A.d(A.f("EXR Invalid compression type"))
break
case"dataWindow":l=n.j()
k=$.A()
k[0]=l
l=$.P()
if(0>=l.length)return A.a(l,0)
j=l[0]
k[0]=n.j()
i=l[0]
k[0]=n.j()
h=l[0]
k[0]=n.j()
a8.sfL(q.a(A.b([j,i,h,l[0]],r)))
l=a8.e
l===$&&A.c(a9)
a8.f=l[2]-l[0]+1
a8.r=l[3]-l[1]+1
break
case"displayWindow":l=n.j()
k=$.A()
k[0]=l
l=$.P()
if(0>=l.length)return A.a(l,0)
j=l[0]
k[0]=n.j()
i=l[0]
k[0]=n.j()
h=l[0]
k[0]=n.j()
a8.sjN(A.b([j,i,h,l[0]],r))
break
case"lineOrder":break
case"pixelAspectRatio":l=n.j()
$.A()[0]=l
l=$.bt()
if(0>=l.length)return A.a(l,0)
break
case"screenWindowCenter":l=n.j()
k=$.A()
k[0]=l
l=$.bt()
if(0>=l.length)return A.a(l,0)
k[0]=n.j()
break
case"screenWindowWidth":l=n.j()
$.A()[0]=l
l=$.bt()
if(0>=l.length)return A.a(l,0)
break
case"tiles":a8.cy=n.j()
a8.db=n.j()
l=n.a
k=n.d++
if(!(k>=0&&k<l.length))return A.a(l,k)
k=l[k]
a8.dx=k&15
a8.dy=B.a.i(k,4)&15
break
case"type":g=n.bO()
if(g!=="deepscanline")if(g!=="deeptile")throw A.d(A.f("EXR Invalid type: "+g))
break
default:break}}if(a8.cx){s=a8.e
s===$&&A.c(a9)
f=s[0]
e=s[2]
d=s[1]
c=s[3]
switch(a8.dx){case 0:b=1
break
case 1:s=Math.max(e-f+1,c-d+1)
r=a8.dy
A.o(s)
b=(r===0?a8.c5(s):a8.c_(s))+1
break
case 2:a=e-f+1
b=(a8.dy===0?a8.c5(a):a8.c_(a))+1
break
default:A.F(A.f(b0))
b=0}a8.fy=b
s=a8.e
f=s[0]
e=s[2]
d=s[1]
c=s[3]
switch(a8.dx){case 0:b=1
break
case 1:s=Math.max(e-f+1,c-d+1)
r=a8.dy
A.o(s)
b=(r===0?a8.c5(s):a8.c_(s))+1
break
case 2:a0=c-d+1
b=(a8.dy===0?a8.c5(a0):a8.c_(a0))+1
break
default:A.F(A.f(b0))
b=0}a8.go=b
if(a8.dx!==2)a8.go=1
s=a8.fy
s.toString
r=a8.e
a8.sio(a8.dC(s,r[0],r[2],a8.cy,a8.dy))
r=a8.go
r.toString
s=a8.e
a8.sip(a8.dC(r,s[1],s[3],a8.db,a8.dy))
s=a8.hb()
a8.id=s
r=a8.cy
r.toString
r=s*r
a8.k1=r
a8.ay=A.kZ(a8.as,a8,r,a8.db)
b3.a=b3.b=0
r=a8.fy
r.toString
s=a8.go
s.toString
a8.se9(A.k1(r*s,new A.h2(b3,a8),!0,t.mC))}else{s=a8.r
s.toString
r=a8.ax=new Uint32Array(s+1)
for(q=p.length,l=a8.e,k=a8.f,a1=0;a1<q;++a1){a2=p[a1]
j=a2.c
j===$&&A.c("size")
k.toString
i=a2.e
i===$&&A.c("xSampling")
a3=B.a.V(j*k,i)
for(j=a2.f,a4=0;a4<s;++a4){l===$&&A.c(a9)
i=l[1]
j===$&&A.c("ySampling")
if(B.a.I(a4+i,j)===0)r[a4]=r[a4]+a3}}for(a5=0,a4=0;a4<s;++a4)a5=Math.max(a5,r[a4])
s=A.kZ(a8.as,a8,a5,null)
a8.ay=s
s=a8.ch=s.bM()
r=a8.ax
q=r.length
p=new Uint32Array(q)
a8.CW=p
for(--q,a6=0,a7=0;a7<=q;++a7){if(B.a.I(a7,s)===0)a6=0
p[a7]=a6
a6+=r[a7]}r=a8.r
r.toString
s=B.a.V(r+s,s)
a8.se9(A.b([new Uint32Array(s-1)],t.mD))}},
c5(a){var s
for(s=0;a>1;){++s
a=B.a.i(a,1)}return s},
c_(a){var s,r
for(s=0,r=0;a>1;){if((a&1)!==0)r=1;++s
a=B.a.i(a,1)}return s+r},
hb(){var s,r,q,p,o
for(s=this.b,r=s.length,q=0,p=0;p<r;++p){o=s[p].c
o===$&&A.c("size")
q+=o}return q},
dC(a,b,c,d,e){var s,r,q,p,o,n,m=J.ah(a,t.p)
for(s=e===1,r=c-b+1,q=0;q<a;++q){p=B.a.B(1,q)
o=B.a.V(r,p)
if(s&&o*p<r)++o
n=Math.max(o,1)
d.toString
m[q]=B.a.V(n+d-1,d)}return m},
sjN(a){t.T.a(a)},
sfL(a){this.e=t.L.a(a)},
se9(a){this.at=t.lq.a(a)},
sio(a){this.fr=t.k.a(a)},
sip(a){this.fx=t.k.a(a)}}
A.h2.prototype={
$1(a){var s,r,q,p,o=this.b,n=o.fr,m=this.a,l=m.b
if(!(l<n.length))return A.a(n,l)
n=n[l]
s=o.fx
r=m.a
if(!(r<s.length))return A.a(s,r)
s=s[r]
q=new Uint32Array(n*s)
p=l+1
m.b=p
if(p===o.fy){m.b=0
m.a=r+1}return q},
$S:26}
A.cI.prototype={
km(a){var s,r,q,p,o,n=this
if(n.cx)for(s=0;s<n.at.length;++s){r=0
while(!0){q=n.at
if(!(s<q.length))return A.a(q,s)
q=q[s]
if(!(r<q.length))break
q[r]=a.d7();++r}}else{q=n.at
if(0>=q.length)return A.a(q,0)
p=q[0].length
for(s=0;s<p;++s){q=n.at
if(0>=q.length)return A.a(q,0)
q=q[0]
o=a.d7()
if(!(s<q.length))return A.a(q,s)
q[s]=o}}}}
A.ei.prototype={
fB(a,b,c){var s,r,q,p=this,o=a.b.length,n=J.ah(o,t.nA)
for(s=0;s<o;++s)n[s]=new A.dy()
p.sfN(t.a3.a(n))
r=p.w
r.toString
q=B.a.F(r*p.x,2)
p.z=new Uint16Array(q)},
bM(){return this.x},
ao(a8,a9,b0,b1,b2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5=this,a6="_channelData",a7="size"
if(b1==null)b1=a5.c.f
if(b2==null)b2=a5.c.ch
b1.toString
s=a9+b1-1
b2.toString
r=b0+b2-1
q=a5.c
p=q.f
p.toString
if(s>p)s=p-1
p=q.r
p.toString
if(r>p)r=p-1
a5.a=s-a9+1
a5.b=r-b0+1
o=q.b
n=o.length
for(m=0,l=0;l<n;++l){k=o[l]
q=a5.y
q===$&&A.c(a6)
if(!(l<q.length))return A.a(q,l)
j=q[l]
j.b=j.a=m
q=k.e
q===$&&A.c("xSampling")
i=B.a.V(a9,q)
h=B.a.V(s,q)
q=i*q<a9?0:1
q=h-i+q
j.c=q
p=k.f
p===$&&A.c("ySampling")
i=B.a.V(b0,p)
h=B.a.V(r,p)
g=i*p<b0?0:1
g=h-i+g
j.d=g
j.e=p
p=k.c
p===$&&A.c(a7)
p=p/2|0
j.f=p
m+=q*g*p}f=a8.k()
e=a8.k()
if(e>=8192)throw A.d(A.f("Error in header for PIZ-compressed data (invalid bitmap size)."))
d=new Uint8Array(8192)
if(f<=e){c=a8.a_(e-f+1)
for(q=c.d,b=c.c-q,p=c.a,g=p.length,a=f,l=0;l<b;++l,a=a0){a0=a+1
a1=q+l
if(!(a1>=0&&a1<g))return A.a(p,a1)
a1=p[a1]
if(!(a<8192))return A.a(d,a)
d[a]=a1}}a2=new Uint16Array(65536)
a3=a5.jb(d,a2)
A.nm(a8,a8.j(),a5.z,m)
for(l=0;l<n;++l){q=a5.y
q===$&&A.c(a6)
if(!(l<q.length))return A.a(q,l)
j=q[l]
a=0
while(!0){q=j.f
q===$&&A.c(a7)
if(!(a<q))break
p=a5.z
p.toString
g=j.a
g===$&&A.c("start")
a1=j.c
a1===$&&A.c("nx")
a4=j.d
a4===$&&A.c("ny")
A.np(p,g+a,a1,q,a4,a1*q,a3);++a}}q=a5.z
q.toString
a5.h5(a2,q,m)
q=a5.r
if(q==null){q=a5.w
q.toString
q=a5.r=A.aq(!1,q*a5.x+73728)}q.a=0
for(;b0<=r;++b0)for(l=0;l<n;++l){q=a5.y
q===$&&A.c(a6)
if(!(l<q.length))return A.a(q,l)
j=q[l]
q=j.e
q===$&&A.c("ys")
if(B.a.I(b0,q)!==0)continue
q=j.c
q===$&&A.c("nx")
p=j.f
p===$&&A.c(a7)
a9=q*p
for(;a9>0;--a9){q=a5.r
q.toString
p=a5.z
p.toString
g=j.b
g===$&&A.c("end")
j.b=g+1
if(!(g>=0&&g<p.length))return A.a(p,g)
q.M(p[g])}}q=a5.r
return A.z(q.c.buffer,0,q.a)},
bp(a,b,c){return this.ao(a,b,c,null,null)},
h5(a,b,c){var s,r,q=t.L
q.a(a)
q.a(b)
for(q=b.length,s=0;s<c;++s){if(!(s<q))return A.a(b,s)
r=b[s]
if(!(r>=0&&r<65536))return A.a(a,r)
b[s]=a[r]}},
jb(a,b){var s,r,q,p,o
for(s=0,r=0;r<65536;++r){if(r!==0){q=r>>>3
if(!(q<8192))return A.a(a,q)
q=(a[q]&1<<(r&7))>>>0!==0}else q=!0
if(q){p=s+1
if(!(s<65536))return A.a(b,s)
b[s]=r
s=p}}for(p=s;p<65536;p=o){o=p+1
if(!(p<65536))return A.a(b,p)
b[p]=0}return s-1},
sfN(a){this.y=t.a3.a(a)}}
A.dy.prototype={}
A.ej.prototype={
bM(){return this.x},
ao(a4,a5,a6,a7,a8){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1=this,a2=B.u.bG(A.bB(t.L.a(a4.S()),1,null,0),!1),a3=a1.y
if(a3==null){a3=a1.w
a3.toString
a3=a1.y=A.aq(!1,a1.x*a3)}a3.a=0
s=A.b([0,0,0,0],t.t)
r=new Uint32Array(1)
q=A.z(r.buffer,0,null)
if(a7==null)a7=a1.c.f
if(a8==null)a8=a1.c.ch
a7.toString
p=a5+a7-1
a8.toString
o=a6+a8-1
a3=a1.c
n=a3.f
n.toString
if(p>n)p=n-1
n=a3.r
n.toString
if(o>n)o=n-1
a1.a=p-a5+1
a1.b=o-a6+1
a3=a3.b
m=a3.length
for(n=q.length,l=a2.length,k=a6,j=0;k<=o;++k)for(i=0;i<m;++i){if(!(i<a3.length))return A.a(a3,i)
h=a3[i]
g=h.f
g===$&&A.c("ySampling")
if(B.a.I(a6,g)!==0)continue
g=h.e
g===$&&A.c("xSampling")
f=B.a.V(a5,g)
e=B.a.V(p,g)
g=f*g<a5?0:1
d=e-f+g
if(0>=1)return A.a(r,0)
r[0]=0
g=h.b
g===$&&A.c("type")
switch(g){case 0:B.b.h(s,0,j)
B.b.h(s,1,s[0]+d)
B.b.h(s,2,s[1]+d)
j=s[2]+d
for(c=0;c<d;++c){g=s[0]
B.b.h(s,0,g+1)
if(!(g>=0&&g<l))return A.a(a2,g)
g=a2[g]
b=s[1]
B.b.h(s,1,b+1)
if(!(b>=0&&b<l))return A.a(a2,b)
b=a2[b]
a=s[2]
B.b.h(s,2,a+1)
if(!(a>=0&&a<l))return A.a(a2,a)
a=a2[a]
r[0]=r[0]+((g<<24|b<<16|a<<8)>>>0)
for(a0=0;a0<4;++a0){g=a1.y
g.toString
if(!(a0<n))return A.a(q,a0)
g.n(q[a0])}}break
case 1:B.b.h(s,0,j)
B.b.h(s,1,s[0]+d)
j=s[1]+d
for(c=0;c<d;++c){g=s[0]
B.b.h(s,0,g+1)
if(!(g>=0&&g<l))return A.a(a2,g)
g=a2[g]
b=s[1]
B.b.h(s,1,b+1)
if(!(b>=0&&b<l))return A.a(a2,b)
b=a2[b]
r[0]=r[0]+((g<<8|b)>>>0)
for(a0=0;a0<2;++a0){g=a1.y
g.toString
if(!(a0<n))return A.a(q,a0)
g.n(q[a0])}}break
case 2:B.b.h(s,0,j)
B.b.h(s,1,s[0]+d)
B.b.h(s,2,s[1]+d)
j=s[2]+d
for(c=0;c<d;++c){g=s[0]
B.b.h(s,0,g+1)
if(!(g>=0&&g<l))return A.a(a2,g)
g=a2[g]
b=s[1]
B.b.h(s,1,b+1)
if(!(b>=0&&b<l))return A.a(a2,b)
b=a2[b]
a=s[2]
B.b.h(s,2,a+1)
if(!(a>=0&&a<l))return A.a(a2,a)
a=a2[a]
r[0]=r[0]+((g<<24|b<<16|a<<8)>>>0)
for(a0=0;a0<4;++a0){g=a1.y
g.toString
if(!(a0<n))return A.a(q,a0)
g.n(q[a0])}}break}}a3=a1.y
return A.z(a3.c.buffer,0,a3.a)},
bp(a,b,c){return this.ao(a,b,c,null,null)}}
A.ek.prototype={
bM(){return 1},
ao(a0,a1,a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=this,b=a0.c,a=A.aq(!1,(b-a0.d)*2)
if(a3==null)a3=c.c.f
if(a4==null)a4=c.c.ch
a3.toString
s=a1+a3-1
a4.toString
r=a2+a4-1
q=c.c
p=q.f
p.toString
if(s>p)s=p-1
q=q.r
q.toString
if(r>q)r=q-1
c.a=s-a1+1
c.b=r-a2+1
for(;q=a0.d,q<b;){p=a0.a
a0.d=q+1
if(!(q>=0&&q<p.length))return A.a(p,q)
q=p[q]
$.a1()[0]=q
q=$.a7()
if(0>=q.length)return A.a(q,0)
o=q[0]
if(o<0){n=-o
for(;m=n-1,n>0;n=m){q=a0.a
p=a0.d++
if(!(p>=0&&p<q.length))return A.a(q,p)
a.n(q[p])}}else for(n=o;m=n-1,n>=0;n=m){q=a0.a
p=a0.d++
if(!(p>=0&&p<q.length))return A.a(q,p)
a.n(q[p])}}l=A.z(a.c.buffer,0,a.a)
for(k=l.length,j=1;j<k;++j)l[j]=l[j-1]+l[j]-128
b=c.r
if(b==null||b.length!==k)b=c.r=new Uint8Array(k)
q=B.a.F(k+1,2)
for(i=0,h=0;!0;q=d,i=f){if(h<k){b.toString
g=h+1
f=i+1
if(!(i<k))return A.a(l,i)
p=l[i]
e=b.length
if(!(h<e))return A.a(b,h)
b[h]=p}else break
if(g<k){h=g+1
d=q+1
if(!(q<k))return A.a(l,q)
q=l[q]
if(!(g<e))return A.a(b,g)
b[g]=q}else break}b.toString
return b},
bp(a,b,c){return this.ao(a,b,c,null,null)}}
A.cJ.prototype={
bM(){return this.w},
ao(a,b,c,d,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=this,e=B.u.bG(A.bB(t.L.a(a.S()),1,null,0),!1)
if(d==null)d=f.c.f
if(a0==null)a0=f.c.ch
d.toString
s=b+d-1
a0.toString
r=c+a0-1
q=f.c
p=q.f
p.toString
if(s>p)s=p-1
q=q.r
q.toString
if(r>q)r=q-1
f.a=s-b+1
f.b=r-c+1
for(o=e.length,n=1;n<o;++n)e[n]=e[n-1]+e[n]-128
q=f.x
if(q==null||q.length!==o)q=f.x=new Uint8Array(o)
p=B.a.F(o+1,2)
for(m=0,l=0;!0;p=g,m=j){if(l<o){q.toString
k=l+1
j=m+1
if(!(m<o))return A.a(e,m)
i=e[m]
h=q.length
if(!(l<h))return A.a(q,l)
q[l]=i}else break
if(k<o){l=k+1
g=p+1
if(!(p<o))return A.a(e,p)
p=e[p]
if(!(k<h))return A.a(q,k)
q[k]=p}else break}q.toString
return q},
bp(a,b,c){return this.ao(a,b,c,null,null)}}
A.cz.prototype={
a4(a){var s=this.a
if(s==null)return null
s=s.d
if(!(a<s.length))return A.a(s,a)
return A.q7(s[a].a,1)},
a6(a){var s
t.L.a(a)
s=new A.h1(A.b([],t.hz))
s.fu(a)
this.a=s
return this.a4(0)}}
A.e7.prototype={
df(a,b,c,d){var s,r=a*3,q=this.d,p=q.length
if(!(r<p))return A.a(q,r)
q[r]=b
s=r+1
if(!(s<p))return A.a(q,s)
q[s]=c
s=r+2
if(!(s<p))return A.a(q,s)
q[s]=d}}
A.cE.prototype={
fw(a){var s,r,q,p,o,n,m,l,k=this
k.a=a.k()
k.b=a.k()
k.c=a.k()
k.d=a.k()
s=a.t()
k.e=(s&64)!==0
if((s&128)!==0){k.f=A.l0(B.a.B(1,(s&7)+1))
for(r=0;q=k.f,r<q.b;++r){p=a.a
o=a.d
n=a.d=o+1
m=p.length
if(!(o>=0&&o<m))return A.a(p,o)
o=p[o]
l=a.d=n+1
if(!(n>=0&&n<m))return A.a(p,n)
n=p[n]
a.d=l+1
if(!(l>=0&&l<m))return A.a(p,l)
q.df(r,o,n,p[l])}}k.x=a.d-a.b}}
A.el.prototype={}
A.e8.prototype={}
A.cD.prototype={
aH(a){var s,r,q,p,o,n,m,l,k,j,i=this
i.b=A.l(t.L.a(a),!1,null,0)
i.a=new A.e8(A.b([],t.b))
if(!i.dS())return null
try{for(;o=i.b,n=o.d,n<o.c;){m=o.a
l=o.d=n+1
k=m.length
if(!(n>=0&&n<k))return A.a(m,n)
s=m[n]
switch(s){case 44:r=i.el()
if(r==null){o=i.a
return o}B.b.A(i.a.r,r)
break
case 33:o.d=l+1
if(!(l>=0&&l<k))return A.a(m,l)
q=m[l]
if(J.au(q,255)){o=i.b
n=o.a
m=o.d++
if(!(m>=0&&m<n.length))return A.a(n,m)
if(o.O(n[m])==="NETSCAPE2.0"){n=o.a
m=o.d
l=o.d=m+1
k=n.length
if(!(m>=0&&m<k))return A.a(n,m)
m=n[m]
o.d=l+1
if(!(l>=0&&l<k))return A.a(n,l)
l=n[l]
if(m===3&&l===1)o.k()}else i.ce()}else if(J.au(q,249)){o=i.b
o.toString
i.iU(o)}else i.ce()
break
case 59:o=i.a
return o
default:break}}}catch(j){p=A.a0(j)
A.jM(p)}return i.a},
iU(a){var s,r,q,p,o,n=this
a.t()
s=a.t()
a.k()
r=a.t()
a.t()
B.a.i(s,2)
q=a.bd(1,0)
p=q.a
q=q.d
if(!(q>=0&&q<p.length))return A.a(p,q)
if(p[q]===44){++a.d
o=n.el()
if(o==null)return
if((s&1)!==0){q=o.f
if(q==null&&n.a.e!=null){q=n.a.e
q=o.f=new A.e7(q.a,q.b,q.c,new Uint8Array(A.b_(q.d)))}if(q!=null)q.c=r}B.b.A(n.a.r,o)}},
a4(a){var s,r,q,p=this,o=p.b
if(o==null||p.a==null)return null
s=p.a.r
r=s.length
if(a>=r||!1)return null
if(!(a<r))return A.a(s,a)
q=s[a]
o.toString
s=q.x
s===$&&A.c("_inputPosition")
o.d=s
return p.hw(q)},
a6(a){if(this.aH(t.L.a(a))==null)return null
return this.a4(0)},
el(){var s,r=this.b
if(r.d>=r.c)return null
s=new A.el()
s.fw(r);++this.b.d
this.ce()
return s},
hw(a){var s,r,q,p,o,n,m,l,k,j,i,h=this
if(h.d==null){h.d=new Uint8Array(256)
h.e=new Uint8Array(4095)
h.f=new Uint8Array(4096)
h.r=new Uint32Array(4096)}s=h.w=h.b.t()
r=B.a.D(1,s)
h.cx=r;++r
h.CW=r
h.ch=r+1;++s
h.ay=s
h.ax=B.a.D(1,s)
h.Q=0
h.at=4098
h.y=h.z=0
h.d[0]=0
s=h.r
s.toString
B.n.ak(s,0,4096,4098)
s=a.c
s===$&&A.c("width")
r=a.d
r===$&&A.c("height")
q=a.a
q===$&&A.c("x")
p=h.a
o=p.a
if(typeof o!=="number")return A.D(o)
if(q+s<=o){q=a.b
q===$&&A.c("y")
o=p.b
if(typeof o!=="number")return A.D(o)
o=q+r>o
q=o}else q=!0
if(q)return null
n=a.f
n=n!=null?n:p.e
h.x=s*r
m=A.T(s,r,B.f,null,null)
l=new Uint8Array(s)
s=a.e
s===$&&A.c("interlaced")
if(s){s=a.b
s===$&&A.c("y")
for(r=s+r,k=0,j=0;k<4;++k)for(i=s+B.be[k];i<r;i+=B.bE[k],++j){if(!h.dT(l))return m
h.er(m,i,n,l)}}else for(i=0;i<r;++i){if(!h.dT(l))return m
h.er(m,i,n,l)}return m},
er(a,b,c,d){var s,r,q,p,o,n,m,l,k,j,i,h,g,f
if(c!=null)for(s=d.length,r=c.d,q=r.length,p=a.x,o=b*a.a,n=p.length,m=0;m<s;++m){l=d[m]
k=l*3
j=l===c.c?0:255
if(!(k<q))return A.a(r,k)
l=r[k]
i=k+1
if(!(i<q))return A.a(r,i)
i=r[i]
h=k+2
if(!(h<q))return A.a(r,h)
h=r[h]
g=B.c.m(B.a.p(j,0,255))
h=B.c.m(B.a.p(h,0,255))
i=B.c.m(B.a.p(i,0,255))
l=B.c.m(B.a.p(l,0,255))
f=o+m
if(!(f>=0&&f<n))return A.a(p,f)
p[f]=(g<<24|h<<16|i<<8|l)>>>0}},
dS(){var s,r,q,p,o,n,m,l,k,j=this,i=j.b.O(6)
if(i!=="GIF87a"&&i!=="GIF89a")return!1
s=j.a
s.toString
s.a=j.b.k()
s=j.a
s.toString
s.b=j.b.k()
r=j.b.t()
j.a.toString
j.b.t();++j.b.d
if((r&128)!==0){s=j.a
s.toString
s.e=A.l0(B.a.B(1,(r&7)+1))
for(q=0;s=j.a.e,q<s.b;++q){p=j.b
o=p.a
n=p.d
m=p.d=n+1
l=o.length
if(!(n>=0&&n<l))return A.a(o,n)
n=o[n]
k=p.d=m+1
if(!(m>=0&&m<l))return A.a(o,m)
m=o[m]
p.d=k+1
if(!(k>=0&&k<l))return A.a(o,k)
s.df(q,n,m,o[k])}}j.a.toString
return!0},
dT(a){var s=this,r=s.x
r.toString
s.x=r-a.length
if(!s.hC(a))return!1
if(s.x===0)s.ce()
return!0},
ce(){var s,r,q,p=this.b
if(p.d>=p.c)return!0
s=p.t()
while(!0){if(s!==0){p=this.b
p=p.d<p.c}else p=!1
if(!p)break
p=this.b
r=p.d+=s
if(r>=p.c)return!0
q=p.a
p.d=r+1
if(!(r>=0&&r<q.length))return A.a(q,r)
s=q[r]}return!0},
hC(a){var s,r,q,p,o,n,m,l,k,j,i,h=this,g="_stack",f="_suffix",e=h.Q
if(e>4095)return!1
s=a.length
if(e!==0){r=0
while(!0){if(!(e!==0&&r<s))break
q=r+1
p=h.e
p===$&&A.c(g)
e=h.Q=e-1
if(!(e>=0))return A.a(p,e)
p=p[e]
if(!(r<s))return A.a(a,r)
a[r]=p
r=q}}else r=0
for(;r<s;){o=h.as=h.hB()
if(o==null)return!1
e=h.CW
if(o===e)return!1
p=h.cx
if(o===p){for(p=h.r,n=0;n<=4095;++n)p[n]=4098
h.ch=e+1
e=h.w+1
h.ay=e
h.ax=B.a.D(1,e)
h.at=4098}else{if(o<p){q=r+1
if(!(r>=0))return A.a(a,r)
a[r]=o
r=q}else{e=h.r
e.toString
if(o>>>0!==o||o>=4096)return A.a(e,o)
if(e[o]===4098){m=h.ch-2
if(o===m){o=h.at
l=h.f
l===$&&A.c(f)
k=h.e
k===$&&A.c(g)
j=h.Q++
p=h.cO(e,o,p)
if(!(j>=0&&j<4095))return A.a(k,j)
k[j]=p
if(!(m>=0&&m<4096))return A.a(l,m)
l[m]=p}else return!1}n=0
while(!0){i=n+1
if(!(n<=4095&&o>h.cx&&o<=4095))break
e=h.e
e===$&&A.c(g)
p=h.Q++
m=h.f
m===$&&A.c(f)
if(!(o>=0&&o<4096))return A.a(m,o)
m=m[o]
if(!(p>=0&&p<4095))return A.a(e,p)
e[p]=m
m=h.r
m.toString
if(!(o<4096))return A.a(m,o)
o=m[o]
n=i}if(i>=4095||o>4095)return!1
e=h.e
e===$&&A.c(g)
p=h.Q++
if(!(p>=0&&p<4095))return A.a(e,p)
e[p]=o
while(!0){e=h.Q
if(!(e!==0&&r<s))break
q=r+1
p=h.e;--e
h.Q=e
if(!(e>=0&&e<4095))return A.a(p,e)
e=p[e]
if(!(r>=0&&r<s))return A.a(a,r)
a[r]=e
r=q}}e=h.at
if(e!==4098){p=h.r
p.toString
m=h.ch-2
if(!(m>=0&&m<4096))return A.a(p,m)
m=p[m]===4098
p=m}else p=!1
if(p){p=h.r
p.toString
m=h.ch-2
if(!(m>=0&&m<4096))return A.a(p,m)
p[m]=e
l=h.as
k=h.f
j=h.cx
if(l===m){k===$&&A.c(f)
k[m]=h.cO(p,e,j)}else{k===$&&A.c(f)
l.toString
k[m]=h.cO(p,l,j)}}e=h.as
e.toString
h.at=e}}return!0},
hB(){var s,r,q,p,o=this
if(o.ay>12)return null
for(;s=o.z,r=o.ay,s<r;){s=o.h7()
s.toString
r=o.y
q=o.z
o.y=(r|B.a.D(s,q))>>>0
o.z=q+8}q=o.y
if(!(r>=0&&r<13))return A.a(B.ap,r)
p=B.ap[r]
o.y=B.a.L(q,r)
o.z=s-r
s=o.ch
if(s<4097){++s
o.ch=s
s=s>o.ax&&r<12}else s=!1
if(s){o.ax=o.ax<<1>>>0
o.ay=r+1}return q&p},
cO(a,b,c){var s,r,q=0
while(!0){if(b>c){s=q+1
r=q<=4095
q=s}else r=!1
if(!r)break
if(b>4095)return 4098
a.toString
if(!(b>=0))return A.a(a,b)
b=a[b]}return b},
h7(){var s,r,q=this,p=q.d,o=p[0]
if(o===0){p[0]=q.b.t()
p=q.d
o=p[0]
if(o===0)return null
B.e.az(p,1,1+o,q.b.a_(o).S())
p=q.d
s=p[1]
p[1]=2
p[0]=p[0]-1}else{r=p[1]
p[1]=r+1
if(!(r<256))return A.a(p,r)
s=p[r]
p[0]=o-1}return s}}
A.h6.prototype={
ci(a){var s,r,q,p,o=this
if(o.dy==null){o.dy=A.aq(!1,8192)
s=A.lj(a,o.c)
o.w=s
o.f=A.mp(a,s,B.a7,!1)
o.r=null
o.x=a.a
o.y=a.b
return}if(o.z===0){s=o.x
s===$&&A.c("_width")
r=o.y
r===$&&A.c("_height")
o.ey(s,r)
o.ev()}o.ex()
s=o.f
r=o.x
r===$&&A.c("_width")
q=o.y
q===$&&A.c("_height")
p=o.w.a
p===$&&A.c("colorMap")
o.dr(s,r,q,p,256);++o.z
p=A.lj(a,o.c)
o.w=p
o.f=A.mp(a,p,B.a7,!1)
o.r=null},
cm(){var s,r,q,p,o,n=this
if(n.dy==null)return null
if(n.z===0){s=n.x
s===$&&A.c("_width")
r=n.y
r===$&&A.c("_height")
n.ey(s,r)
n.ev()}else n.ex()
s=n.f
r=n.x
r===$&&A.c("_width")
q=n.y
q===$&&A.c("_height")
p=n.w.a
p===$&&A.c("colorMap")
n.dr(s,r,q,p,256)
n.dy.n(59)
n.w=n.f=null
n.z=0
p=n.dy
o=A.z(p.c.buffer,0,p.a)
n.dy=null
return o},
dr(a,b,c,d,e){var s,r=this
r.dy.n(44)
r.dy.M(0)
r.dy.M(0)
r.dy.M(b)
r.dy.M(c)
r.dy.n(135)
r.dy.T(d)
for(s=e;s<256;++s){r.dy.n(0)
r.dy.n(0)
r.dy.n(0)}r.hL(a,b,c)},
hL(a,b,c){var s,r,q,p,o,n,m,l,k,j,i,h,g=this,f={}
g.dx=g.as=g.Q=0
g.db=new Uint8Array(256)
g.dy.n(8)
s=new Int32Array(5003)
r=new Int32Array(5003)
f.a=b*c
f.b=0
g.at=g.ax=9
g.ch=511
g.CW=256
g.ay=257
g.cy=!1
g.cx=258
q=new A.h7(f,a)
p=q.$0()
for(o=0,n=5003;n<65536;n*=2)++o
o=8-o
for(m=0;m<5003;++m)s[m]=-1
g.bz(g.CW)
for(l=!0;l;){k=q.$0()
for(l=!1;k!==-1;){n=(k<<12>>>0)+p
m=(B.a.D(k,o)^p)>>>0
if(!(m<5003))return A.a(s,m)
j=s[m]
if(j===n){p=r[m]
k=q.$0()
continue}else if(j>=0){i=5003-m
if(m===0)i=1
do{m-=i
if(m<0)m+=5003
if(!(m>=0&&m<5003))return A.a(s,m)
j=s[m]
if(j===n){p=r[m]
l=!0
break}}while(j>=0)
if(l)break}g.bz(p)
j=g.cx
if(j<4096){g.cx=j+1
r[m]=j
s[m]=n}else{for(m=0;m<5003;++m)s[m]=-1
j=g.CW
g.cx=j+2
g.cy=!0
g.bz(j)}h=q.$0()
p=k
k=h}}g.bz(p)
g.bz(g.ay)
g.dy.n(0)},
bz(a){var s,r=this,q=r.Q,p=r.as
if(!(p>=0&&p<17))return A.a(B.aG,p)
q&=B.aG[p]
r.Q=q
if(p>0){q=(q|B.a.B(a,p))>>>0
r.Q=q}else{r.Q=a
q=a}p+=r.at
r.as=p
for(;p>=8;){r.dt(q&255)
q=B.a.i(r.Q,8)
r.Q=q
p=r.as-=8}if(r.cx>r.ch||r.cy)if(r.cy){s=r.ax
r.at=s
r.ch=B.a.B(1,s)-1
r.cy=!1}else{s=++r.at
if(s===12)r.ch=4096
else r.ch=B.a.B(1,s)-1}if(a===r.ay){for(;p>0;){r.dt(q&255)
q=B.a.i(r.Q,8)
r.Q=q
p=r.as-=8}r.ew()}},
ew(){var s,r=this,q=r.dx
if(q>0){r.dy.n(q)
q=r.dy
q.toString
s=r.db
s===$&&A.c("_block")
q.bT(s,r.dx)
r.dx=0}},
dt(a){var s,r,q=this,p=q.db
p===$&&A.c("_block")
s=q.dx
r=s+1
q.dx=r
if(!(s<256))return A.a(p,s)
p[s]=a
if(r>=254)q.ew()},
ev(){var s,r=this
r.dy.n(33)
r.dy.n(255)
r.dy.n(11)
r.dy.T(new A.a8("NETSCAPE2.0"))
s=r.dy
s.toString
s.T(A.b([3,1],t.t))
r.dy.M(0)
r.dy.n(0)},
ex(){var s,r=this
r.dy.n(33)
r.dy.n(249)
r.dy.n(4)
r.dy.n(0)
s=r.dy
s.M(80)
r.dy.n(0)
r.dy.n(0)},
ey(a,b){var s=this
s.dy.T(new A.a8("GIF89a"))
s.dy.M(a)
s.dy.M(b)
s.dy.n(0)
s.dy.n(0)
s.dy.n(0)}}
A.h7.prototype={
$0(){var s=this.a,r=s.a
if(r===0)return-1
s.a=r-1
r=this.b
r.toString
s=s.b++
if(!(s<r.length))return A.a(r,s)
return r[s]&255},
$S:27}
A.cG.prototype={
a4(b4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2=null,b3=this.a
if(b3!=null){s=this.b
s=s==null||b4>=s.e}else s=!0
if(s)return b2
s=this.b.f
if(!(b4<s.length))return A.a(s,b4)
r=s[b4]
s=b3.a
b3=b3.b+r.e
q=r.d
p=J.fI(s,b3,b3+q)
o=new A.c8()
if(o.bm(p))return o.a6(p)
n=A.aq(!1,14)
n.M(19778)
n.P(q)
n.P(0)
n.P(0)
b3=A.l(p,!1,b2,0)
s=A.kO(A.l(A.z(n.c.buffer,0,n.a),!1,b2,0))
q=b3.j()
m=b3.j()
l=$.A()
l[0]=m
m=$.P()
if(0>=m.length)return A.a(m,0)
k=m[0]
l[0]=b3.j()
j=m[0]
i=b3.k()
h=b3.k()
g=b3.j()
f=A.cR([0,B.O,3,B.N],t.p,t.G).q(0,g)
if(f==null)A.F(A.f("Bitmap compression "+g+" is not supported yet."))
g=b3.j()
l[0]=b3.j()
e=m[0]
l[0]=b3.j()
m=m[0]
l=b3.j()
d=new A.eb(s,j,k,q,i,h,f,g,e,m,l,b3.j())
d.dm(b3,s)
if(q!==40&&i!==1)return b2
c=l===0&&h<=8?40+4*B.a.B(1,h):40+4*l
s.b=c
n.a-=4
n.P(c)
b=A.l(p,!1,b2,0)
a=new A.e_()
a.a=b
a.b=d
a0=a.a4(0)
if(h>=32)return a0
a1=32-B.a.I(k,32)
a2=B.a.F(a1===32?k:k+a1,8)
for(b3=a0.x,s=a0.a,q=b3.length,m=a0.b-1,l=1/j<0,i=j<0,j=j===0,a3=0;a3<B.a.F(A.b6.prototype.gb9.call(d,d),2);++a3){a4=!(j?l:i)?a3:m-a3
a5=b.R(a2)
b.d=b.d+(a5.c-a5.d)
for(h=a4*s,a6=0;a6<k;){g=a5.a
e=a5.d++
if(!(e>=0&&e<g.length))return A.a(g,e)
e=g[e]
a7=7
while(!0){if(!(a7>-1&&a6<k))break
if((e&B.a.D(1,a7))>>>0!==0){g=h+a6
a8=B.c.m(B.a.p(0,0,255))
a9=B.c.m(B.a.p(0,0,255))
b0=B.c.m(B.a.p(0,0,255))
b1=B.c.m(B.a.p(0,0,255))
if(!(g>=0&&g<q))return A.a(b3,g)
b3[g]=(a8<<24|a9<<16|b0<<8|b1)>>>0}++a6;--a7}}}return a0},
a6(a){var s=A.l(t.L.a(a),!1,null,0)
this.a=s
s=A.l3(s)
this.b=s
if(s==null)return null
return this.a4(0)}}
A.he.prototype={}
A.hf.prototype={
$1(a){var s
A.o(a)
s=this.a
s.t()
s.t()
s.t();++s.d
s.k()
s.k()
return new A.c2(s.j(),s.j())},
$S:28}
A.c2.prototype={}
A.eb.prototype={
gb9(a){return B.a.F(A.b6.prototype.gb9.call(this,this),2)},
gco(){return this.r===40&&this.x===32?!1:A.b6.prototype.gco.call(this)}}
A.it.prototype={
jQ(a){var s,r,q,p,o,n,m,l
t.aL.a(a)
s=A.aq(!1,8192)
s.M(0)
s.M(1)
s.M(1)
r=A.b([A.b([],t.t)],t.S)
for(q=22,p=0,o=0;o<1;++o){n=a[o]
m=n.a
if(m>256||n.b>256)throw A.d(A.kX("ICO and CUR support only sizes until 256"))
s.n(m)
s.n(n.b)
s.n(0)
s.n(0)
s.M(0)
s.M(32)
m=A.lk(null)
m.at=!1
m.ci(n)
l=m.cm()
m=l.length
s.P(m)
s.P(q)
q+=m;++p
B.b.A(r,l)}for(m=r.length,o=0;o<r.length;r.length===m||(0,A.b3)(r),++o)s.T(r[o])
return A.z(s.c.buffer,0,s.a)}}
A.hd.prototype={}
A.dX.prototype={}
A.hq.prototype={}
A.az.prototype={
sfO(a){this.r=t.hK.a(a)}}
A.hr.prototype={
kH(a){var s,r,q,p,o,n,m,l=this,k=A.l(t.L.a(a),!0,null,0)
l.a=k
s=k.bd(2,0)
k=s.a
r=s.d
q=k.length
if(!(r>=0&&r<q))return A.a(k,r)
if(k[r]===255){++r
if(!(r<q))return A.a(k,r)
r=k[r]!==216
k=r}else k=!0
if(k)return!1
if(l.bh()!==216)return!1
p=l.bh()
o=!1
n=!1
while(!0){if(p!==217){k=l.a
k=k.d<k.c}else k=!1
if(!k)break
m=l.a.k()
if(m<2)break
k=l.a
k.d=k.d+(m-2)
switch(p){case 192:case 193:case 194:o=!0
break
case 218:n=!0
break}p=l.bh()}return o&&n},
kk(a){var s,r,q,p,o,n,m,l,k=this
k.a=A.l(t.L.a(a),!0,null,0)
k.iL()
if(k.x.length!==1)throw A.d(A.f("Only single frame JPEGs supported"))
for(s=k.Q,r=0;q=k.d,p=q.z,r<p.length;++r){o=q.y.q(0,p[r])
q=o.a
p=k.d
n=p.f
m=o.b
l=p.r
p=k.h9(p,o)
q=q===1&&n===2?1:0
B.b.A(s,new A.dX(p,q,m===1&&l===2?1:0))}},
iL(){var s,r,q,p,o,n,m,l,k=this
if(k.bh()!==216)throw A.d(A.f("Start Of Image marker not found."))
s=k.bh()
while(!0){if(s!==217){r=k.a
r===$&&A.c("input")
r=r.d<r.c}else r=!1
if(!r)break
r=k.a
r===$&&A.c("input")
q=r.k()
if(q<2)A.F(A.f("Invalid Block"))
r=k.a
p=r.R(q-2)
r.d=r.d+(p.c-p.d)
switch(s){case 224:case 225:case 226:case 227:case 228:case 229:case 230:case 231:case 232:case 233:case 234:case 235:case 236:case 237:case 238:case 239:case 254:k.iM(s,p)
break
case 219:k.iP(p)
break
case 192:case 193:case 194:k.iT(s,p)
break
case 195:case 197:case 198:case 199:case 200:case 201:case 202:case 203:case 205:case 206:case 207:throw A.d(A.f("Unhandled frame type "+B.a.bo(s,16)))
case 196:k.iO(p)
break
case 221:k.e=p.k()
break
case 218:k.j4(p)
break
case 255:r=k.a
o=r.a
n=r.d
if(!(n>=0&&n<o.length))return A.a(o,n)
if(o[n]!==255)r.d=n-1
break
default:r=k.a
o=r.a
n=r.d
m=n+-3
l=o.length
if(!(m>=0&&m<l))return A.a(o,m)
if(o[m]===255){m=n+-2
if(!(m>=0&&m<l))return A.a(o,m)
m=o[m]
o=m>=192&&m<=254}else o=!1
if(o){r.d=n-3
break}if(s!==0)throw A.d(A.f("Unknown JPEG marker "+B.a.bo(s,16)))
break}s=k.bh()}},
bh(){var s,r=this,q=r.a
q===$&&A.c("input")
if(q.d>=q.c)return 0
do{do{s=r.a.t()
if(s!==255){q=r.a
q=q.d<q.c}else q=!1}while(q)
q=r.a
if(q.d>=q.c)return s
do{s=r.a.t()
if(s===255){q=r.a
q=q.d<q.c}else q=!1}while(q)
if(s===0){q=r.a
q=q.d<q.c}else q=!1}while(q)
return s},
iS(a,b,c){var s,r,q,p,o,n,m=a.c,l=m-a.d
try{switch(b){case 6:o=a.t()
$.a1()[0]=o
o=$.a7()
if(0>=o.length)return A.a(o,0)
o=o[0]
return o
case 1:case 7:o=a.t()
return o
case 2:o=a.O(1)
return o
case 3:o=a.k()
return o
case 4:o=a.j()
return o
case 5:case 10:s=a.bd(8,c)
o=s.j()
n=$.A()
n[0]=o
o=$.P()
if(0>=o.length)return A.a(o,0)
r=o[0]
n[0]=s.j()
if(0>=o.length)return A.a(o,0)
q=o[0]
if(J.au(q,0))return 0
o=r
n=q
if(typeof o!=="number")return o.kL()
if(typeof n!=="number")return A.D(n)
return o/n
case 8:o=a.k()
$.a6()[0]=o
o=$.ag()
if(0>=o.length)return A.a(o,0)
o=o[0]
return o
case 9:o=a.j()
$.A()[0]=o
o=$.P()
if(0>=o.length)return A.a(o,0)
o=o[0]
return o
case 11:o=a.j()
$.A()[0]=o
o=$.bt()
if(0>=o.length)return A.a(o,0)
o=o[0]
return o
case 12:o=a.bd(8,c).cp()
return o
default:return 0}}finally{o=l
n=a.d
if(typeof o!=="number")return o.ac()
p=o-(m-n)
m=p
if(typeof m!=="number")return m.dd()
if(m<4){m=p
if(typeof m!=="number")return A.D(m)
a.d=n+A.o(4-m)}}},
iR(a){var s,r,q,p,o,n,m,l,k=a.k()
for(s=this.r.b,r=a.c,q=0;q<k;++q){p=a.k()
o=a.k()
n=a.j()
if(o-1>=12)continue
if(n>65536)continue
if(!(o<13))return A.a(B.az,o)
m=B.az[o]
if(m>4){l=a.j()
if(l+m>r-a.d)continue}else l=0
s.h(0,p,this.iS(a,o,l))}},
iQ(a){var s,r,q,p,o=this.r
if(o.a==null)o.seS(A.b([],t.i))
s=B.e.cq(a.S(),0)
o=o.a
o.toString
B.b.A(o,s)
if(a.j()!==1165519206)return
if(a.k()!==0)return
r=a.e
q=a.O(2)
if(q==="II")a.e=!1
else if(q==="MM")a.e=!0
else return
a.d+=2
p=a.j()
if(p<8||p>16)if(p>a.c-a.d-16){a.e=r
return}if(p>8)a.d+=p-8
this.iR(a)
a.e=r},
iM(a,b){var s,r,q,p,o,n=b
if(a===224){s=n
r=s.a
s=s.d
if(!(s>=0&&s<r.length))return A.a(r,s)
if(r[s]===74){s=n
r=s.a
s=s.d+1
if(!(s>=0&&s<r.length))return A.a(r,s)
if(r[s]===70){s=n
r=s.a
s=s.d+2
if(!(s>=0&&s<r.length))return A.a(r,s)
if(r[s]===73){s=n
r=s.a
s=s.d+3
if(!(s>=0&&s<r.length))return A.a(r,s)
if(r[s]===70){s=n
r=s.a
s=s.d+4
if(!(s>=0&&s<r.length))return A.a(r,s)
s=r[s]===0}else s=!1}else s=!1}else s=!1}else s=!1
if(s){s=this.b=new A.hu()
r=n
q=r.a
r=r.d+5
if(!(r>=0&&r<q.length))return A.a(q,r)
q=n
r=q.a
q=q.d+6
if(!(q>=0&&q<r.length))return A.a(r,q)
r=n
q=r.a
r=r.d+7
if(!(r>=0&&r<q.length))return A.a(q,r)
q=n
r=q.a
q=q.d+8
if(!(q>=0&&q<r.length))return A.a(r,q)
r=n
q=r.a
r=r.d+9
if(!(r>=0&&r<q.length))return A.a(q,r)
q=n
r=q.a
q=q.d+10
if(!(q>=0&&q<r.length))return A.a(r,q)
r=n
q=r.a
r=r.d+11
if(!(r>=0&&r<q.length))return A.a(q,r)
q=n
r=q.a
q=q.d+12
if(!(q>=0&&q<r.length))return A.a(r,q)
q=r[q]
s.f=q
r=n
p=r.a
r=r.d+13
if(!(r>=0&&r<p.length))return A.a(p,r)
r=p[r]
s.r=r
n.bd(14+3*q*r,14)}}else if(a===225)this.iQ(n)
else if(a===238){s=n
r=s.a
s=s.d
if(!(s>=0&&s<r.length))return A.a(r,s)
if(r[s]===65){s=n
r=s.a
s=s.d+1
if(!(s>=0&&s<r.length))return A.a(r,s)
if(r[s]===100){s=n
r=s.a
s=s.d+2
if(!(s>=0&&s<r.length))return A.a(r,s)
if(r[s]===111){s=n
r=s.a
s=s.d+3
if(!(s>=0&&s<r.length))return A.a(r,s)
if(r[s]===98){s=n
r=s.a
s=s.d+4
if(!(s>=0&&s<r.length))return A.a(r,s)
if(r[s]===101){s=n
r=s.a
s=s.d+5
if(!(s>=0&&s<r.length))return A.a(r,s)
s=r[s]===0}else s=!1}else s=!1}else s=!1}else s=!1}else s=!1
if(s){s=new A.hq()
this.c=s
r=n
q=r.a
r=r.d+6
if(!(r>=0&&r<q.length))return A.a(q,r)
q=n
r=q.a
q=q.d+7
if(!(q>=0&&q<r.length))return A.a(r,q)
r=n
q=r.a
r=r.d+8
if(!(r>=0&&r<q.length))return A.a(q,r)
q=n
r=q.a
q=q.d+9
if(!(q>=0&&q<r.length))return A.a(r,q)
r=n
q=r.a
r=r.d+10
if(!(r>=0&&r<q.length))return A.a(q,r)
q=n
r=q.a
q=q.d+11
if(!(q>=0&&q<r.length))return A.a(r,q)
s.d=r[q]}}else if(a===254)try{n.kp()}catch(o){A.an(o)}},
iP(a){var s,r,q,p,o,n,m,l,k,j
for(s=a.c,r=this.w;q=a.d,p=q<s,p;){p=a.a
a.d=q+1
if(!(q>=0&&q<p.length))return A.a(p,q)
q=p[q]
o=B.a.i(q,4)
n=q&15
if(n>=4)throw A.d(A.f("Invalid number of quantization tables"))
if(r[n]==null)B.b.h(r,n,new Int16Array(64))
m=r[n]
for(q=o!==0,l=0;l<64;++l){if(q)k=a.k()
else{p=a.a
j=a.d++
if(!(j>=0&&j<p.length))return A.a(p,j)
k=p[j]}m.toString
p=B.m[l]
if(!(p<64))return A.a(m,p)
m[p]=k}}if(p)throw A.d(A.f("Bad length for DQT block"))},
iT(a,b){var s,r,q,p,o,n,m,l,k,j=this
if(j.d!=null)throw A.d(A.f("Duplicate JPG frame data found."))
s=j.d=new A.eu(A.J(t.p,t.e7),A.b([],t.t))
s.b=a===194
s.c=b.t()
s=j.d
s.toString
s.d=b.k()
s=j.d
s.toString
s.e=b.k()
r=b.t()
for(s=j.w,q=0;q<r;++q){p=b.a
o=b.d
n=b.d=o+1
m=p.length
if(!(o>=0&&o<m))return A.a(p,o)
o=p[o]
l=b.d=n+1
if(!(n>=0&&n<m))return A.a(p,n)
n=p[n]
k=B.a.i(n,4)
b.d=l+1
if(!(l>=0&&l<m))return A.a(p,l)
l=p[l]
B.b.A(j.d.z,o)
j.d.y.h(0,o,new A.az(k&15,n&15,s,l))}j.d.kh()
B.b.A(j.x,j.d)},
iO(a){var s,r,q,p,o,n,m,l,k,j,i,h
for(s=a.c,r=this.z,q=this.y;p=a.d,p<s;){o=a.a
n=p+1
a.d=n
if(!(p>=0&&p<o.length))return A.a(o,p)
m=o[p]
l=new Uint8Array(16)
for(p=n,k=0,j=0;j<16;++j,p=n){n=p+1
a.d=n
if(!(p>=0&&p<o.length))return A.a(o,p)
p=o[p]
if(!(j<16))return A.a(l,j)
l[j]=p
k+=l[j]}i=new Uint8Array(k)
for(j=0;j<k;++j,p=n){n=p+1
a.d=n
if(!(p>=0&&p<o.length))return A.a(o,p)
p=o[p]
if(!(j<k))return A.a(i,j)
i[j]=p}if((m&16)!==0){m-=16
h=q}else h=r
if(h.length<=m)B.b.sv(h,m+1)
B.b.h(h,m,this.ha(l,i))}},
j4(a){var s,r,q,p,o,n,m,l=this,k=a.t()
if(k<1||k>4)throw A.d(A.f("Invalid SOS block"))
s=A.k1(k,new A.hs(l,a),!0,t.e7)
r=a.t()
q=a.t()
p=a.t()
o=B.a.i(p,4)
n=l.a
n===$&&A.c("input")
m=l.d
o=new A.ev(n,m,s,l.e,r,q,o&15,p&15)
n=m.w
n===$&&A.c("mcusPerLine")
o.f=n
o.r=m.b
o.aK()},
ha(a,b){var s,r,q,p,o,n,m,l,k,j,i=A.b([],t.kv),h=16
while(!0){if(!(h>0&&a[h-1]===0))break;--h}B.b.A(i,new A.ch([]))
if(0>=i.length)return A.a(i,0)
s=i[0]
for(r=b.length,q=0,p=0;p<h;){for(o=0;o<a[p];++o){if(0>=i.length)return A.a(i,-1)
s=i.pop()
n=s.a
m=n.length
l=s.b
if(m<=l)B.b.sv(n,l+1)
m=s.b
if(!(q>=0&&q<r))return A.a(b,q)
B.b.h(n,m,b[q])
for(;n=s.b,n>0;){if(0>=i.length)return A.a(i,-1)
s=i.pop()}s.b=n+1
B.b.A(i,s)
for(;i.length<=p;s=k){n=[]
k=new A.ch(n)
B.b.A(i,k)
m=s.a
l=m.length
j=s.b
if(l<=j)B.b.sv(m,j+1)
B.b.h(m,s.b,n)}++q}++p
if(p<h){n=[]
k=new A.ch(n)
B.b.A(i,k)
m=s.a
l=m.length
j=s.b
if(l<=j)B.b.sv(m,j+1)
B.b.h(m,s.b,n)
s=k}}if(0>=i.length)return A.a(i,0)
return i[0].a},
h9(a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2=a4.e
a2===$&&A.c("blocksPerLine")
s=a4.f
s===$&&A.c("blocksPerColumn")
r=a2<<3>>>0
q=new Int32Array(64)
p=new Uint8Array(64)
o=s*8
n=A.H(o,null,!1,t.nh)
for(m=a4.c,l=a4.d,k=0,j=0;j<s;++j){i=j<<3>>>0
for(h=0;h<8;++h,k=g){g=k+1
B.b.h(n,k,new Uint8Array(r))}for(f=0;f<a2;++f){if(!(l>=0&&l<4))return A.a(m,l)
e=m[l]
e.toString
d=a4.r
d===$&&A.c("blocks")
if(!(j<d.length))return A.a(d,j)
d=d[j]
if(!(f<d.length))return A.a(d,f)
A.qi(e,d[f],p,q)
c=f<<3>>>0
for(b=0,a=0;a<8;++a){e=i+a
if(!(e<o))return A.a(n,e)
a0=n[e]
for(h=0;h<8;++h,b=a1){a0.toString
e=c+h
a1=b+1
if(!(b>=0&&b<64))return A.a(p,b)
d=p[b]
if(!(e<a0.length))return A.a(a0,e)
a0[e]=d}}}}return n}}
A.hs.prototype={
$1(a){var s,r,q,p,o,n=this.b,m=n.t(),l=n.t()
n=this.a
if(!n.d.y.a3(m))throw A.d(A.f("Invalid Component in SOS block"))
s=n.d.y.q(0,m)
s.toString
r=B.a.i(l,4)&15
q=l&15
p=n.z
o=p.length
if(r<o){if(!(r<o))return A.a(p,r)
p=p[r]
p.toString
s.w=p}n=n.y
p=n.length
if(q<p){if(!(q<p))return A.a(n,q)
n=n[q]
n.toString
s.x=n}return s},
$S:29}
A.ch.prototype={}
A.eu.prototype={
kh(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a=this
for(s=a.y,r=A.w(s).c,q=A.cQ(s,s.r,r);q.C();){p=s.q(0,q.d)
a.sk8(Math.max(a.f,p.a))
a.sk9(Math.max(a.r,p.b))}q=a.e
q.toString
a.w=B.c.bk(q/8/a.f)
q=a.d
q.toString
a.x=B.c.bk(q/8/a.r)
for(r=A.cQ(s,s.r,r),q=t.hK,o=t.bW,n=t.kn;r.C();){m=s.q(0,r.d)
m.toString
l=a.e
l.toString
k=m.a
j=B.c.bk(B.c.bk(l/8)*k/a.f)
l=a.d
l.toString
i=m.b
h=B.c.bk(B.c.bk(l/8)*i/a.r)
g=a.w*k
f=a.x*i
e=J.ah(f,n)
for(d=0;d<f;++d){c=J.ah(g,o)
for(b=0;b<g;++b)c[b]=new Int32Array(64)
e[d]=c}m.e=j
m.f=h
m.sfO(q.a(e))}},
sk8(a){this.f=A.o(a)},
sk9(a){this.r=A.o(a)}}
A.hu.prototype={}
A.ev.prototype={
aK(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=this,a1="blocksPerLine",a2=a0.y,a3=a2.length,a4=a0.r
a4.toString
if(a4)if(a0.Q===0)s=a0.at===0?a0.ghs():a0.ghu()
else s=a0.at===0?a0.ghk():a0.ghm()
else s=a0.ghp()
a4=a3===1
if(a4){if(0>=a3)return A.a(a2,0)
r=a2[0]
q=r.e
q===$&&A.c(a1)
r=r.f
r===$&&A.c("blocksPerColumn")
p=q*r}else{r=a0.f
r===$&&A.c("mcusPerLine")
q=a0.b.x
q===$&&A.c("mcusPerColumn")
p=r*q}r=a0.z
if(r==null||r===0)a0.z=p
for(r=a0.a,q=t.mX,o=0;o<p;){for(n=0;n<a3;++n){if(!(n<a2.length))return A.a(a2,n)
a2[n].y=0}a0.CW=0
if(a4){if(0>=a2.length)return A.a(a2,0)
m=a2[0]
l=0
while(!0){k=a0.z
k.toString
if(!(l<k))break
q.a(s)
k=m.e
k===$&&A.c(a1)
j=B.a.V(o,k)
i=B.a.I(o,k)
k=m.r
k===$&&A.c("blocks")
if(!(j>=0&&j<k.length))return A.a(k,j)
k=k[j]
if(!(i>=0&&i<k.length))return A.a(k,i)
s.$2(m,k[i]);++o;++l}}else{l=0
while(!0){k=a0.z
k.toString
if(!(l<k))break
for(n=0;n<a3;++n){if(!(n<a2.length))return A.a(a2,n)
m=a2[n]
h=m.a
g=m.b
for(f=0;f<g;++f)for(e=0;e<h;++e)a0.hx(m,s,o,f,e)}++o;++l}}a0.ch=0
k=r.a
d=r.d
c=k.length
if(!(d>=0&&d<c))return A.a(k,d)
b=k[d]
a=d+1
if(!(a<c))return A.a(k,a)
a=k[a]
if(b===255)if(a>=208&&a<=215)r.d=d+2
else break}},
b5(){var s,r,q=this,p=q.ch
if(p>0){--p
q.ch=p
return B.a.a8(q.ay,p)&1}p=q.a
if(p.d>=p.c)return null
s=p.t()
q.ay=s
if(s===255){r=p.t()
if(r!==0)throw A.d(A.f("unexpected marker: "+B.a.bo((q.ay<<8|r)>>>0,16)))}q.ch=7
return B.a.i(q.ay,7)&1},
by(a){var s,r,q
for(s=t.j,r=a;q=this.b5(),q!=null;){r=J.kI(s.a(r),q)
if(typeof r=="number")return B.c.m(r)}return null},
cY(a){var s,r
for(s=0;a>0;){r=this.b5()
if(r==null)return null
s=(s<<1|r)>>>0;--a}return s},
bB(a){var s
if(a===1)return this.b5()===1?1:-1
a.toString
s=this.cY(a)
s.toString
if(s>=B.a.D(1,a-1))return s
return s+B.a.D(-1,a)+1},
hq(a,b){var s,r,q,p,o,n,m=this,l=a.w
l===$&&A.c("huffmanTableDC")
s=m.by(l)
r=s===0?0:m.bB(s)
l=a.y
l===$&&A.c("pred")
l+=r
a.y=l
b[0]=l
for(q=1;q<64;){l=a.x
l===$&&A.c("huffmanTableAC")
l=m.by(l)
l.toString
p=l&15
o=B.a.i(l,4)
if(p===0){if(o<15)break
q+=16
continue}q+=o
p=m.bB(p)
if(!(q>=0&&q<80))return A.a(B.m,q)
n=B.m[q]
if(!(n<64))return A.a(b,n)
b[n]=p;++q}},
ht(a,b){var s,r,q=a.w
q===$&&A.c("huffmanTableDC")
s=this.by(q)
r=s===0?0:B.a.B(this.bB(s),this.ax)
q=a.y
q===$&&A.c("pred")
q+=r
a.y=q
b[0]=q},
hv(a,b){var s,r
t.L.a(b)
s=b[0]
r=this.b5()
r.toString
b[0]=(s|B.a.B(r,this.ax))>>>0},
hl(a,b){var s,r,q,p,o,n,m,l=this,k=l.CW
if(k>0){l.CW=k-1
return}s=l.Q
r=l.as
for(k=l.ax;s<=r;){q=a.x
q===$&&A.c("huffmanTableAC")
q=l.by(q)
q.toString
p=q&15
o=B.a.i(q,4)
if(p===0){if(o<15){k=l.cY(o)
k.toString
l.CW=k+B.a.B(1,o)-1
break}s+=16
continue}s+=o
if(!(s>=0&&s<80))return A.a(B.m,s)
n=B.m[s]
q=l.bB(p)
m=B.a.B(1,k)
if(!(n<64))return A.a(b,n)
b[n]=q*m;++s}},
hn(a,b){var s,r,q,p,o,n,m,l,k,j=this
t.L.a(b)
s=j.Q
r=j.as
for(q=j.ax,p=0;s<=r;){if(!(s>=0&&s<80))return A.a(B.m,s)
o=B.m[s]
n=j.cx
switch(n){case 0:n=a.x
n===$&&A.c("huffmanTableAC")
m=j.by(n)
if(m==null)throw A.d(A.f("Invalid progressive encoding"))
l=m&15
p=B.a.i(m,4)
if(l===0)if(p<15){n=j.cY(p)
n.toString
j.CW=n+B.a.B(1,p)
j.cx=4}else{j.cx=1
p=16}else{if(l!==1)throw A.d(A.f("invalid ACn encoding"))
j.cy=j.bB(l)
j.cx=p!==0?2:3}continue
case 1:case 2:if(!(o<64))return A.a(b,o)
k=b[o]
if(k!==0){n=j.b5()
n.toString
n=B.a.B(n,q)
if(!(o<64))return A.a(b,o)
b[o]=k+n}else{--p
if(p===0)j.cx=n===2?3:0}break
case 3:if(!(o<64))return A.a(b,o)
n=b[o]
if(n!==0){k=j.b5()
k.toString
k=B.a.B(k,q)
if(!(o<64))return A.a(b,o)
b[o]=n+k}else{n=j.cy
n===$&&A.c("successiveACNextValue")
n=B.a.B(n,q)
if(!(o<64))return A.a(b,o)
b[o]=n
j.cx=0}break
case 4:if(!(o<64))return A.a(b,o)
n=b[o]
if(n!==0){k=j.b5()
k.toString
k=B.a.B(k,q)
if(!(o<64))return A.a(b,o)
b[o]=n+k}break}++s}if(j.cx===4)if(--j.CW===0)j.cx=0},
hx(a,b,c,d,e){var s,r,q,p,o
t.mX.a(b)
s=this.f
s===$&&A.c("mcusPerLine")
r=B.a.V(c,s)*a.b+d
q=B.a.I(c,s)*a.a+e
s=a.r
s===$&&A.c("blocks")
p=s.length
if(r>=p)return
if(!(r>=0))return A.a(s,r)
s=s[r]
o=s.length
if(q>=o)return
if(!(q>=0))return A.a(s,q)
b.$2(a,s[q])}}
A.c7.prototype={
a6(a){var s
t.L.a(a)
s=A.lc()
s.kk(a)
if(s.x.length!==1)throw A.d(A.f("only single frame JPEGs supported"))
return A.q0(s)}}
A.ht.prototype={
fc(a){a=B.c.m(B.a.p(a,1,100))
if(this.ch===a)return
this.i8(a<50?B.c.cn(5000/a):B.a.cn(200-a*2))
this.ch=a},
b7(b2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0=this,b1=A.aq(!0,8192)
b1.n(255)
b1.n(216)
b1.n(255)
b1.n(224)
b1.M(16)
b1.n(74)
b1.n(70)
b1.n(73)
b1.n(70)
b1.n(0)
b1.n(1)
b1.n(1)
b1.n(0)
b1.M(1)
b1.M(1)
b1.n(0)
b1.n(0)
b0.jj(b1,b2.y)
b0.jl(b1)
s=b2.a
r=b2.b
b1.n(255)
b1.n(192)
b1.M(17)
b1.n(8)
b1.M(r)
b1.M(s)
b1.n(3)
b1.n(1)
b1.n(17)
b1.n(0)
b1.n(2)
b1.n(17)
b1.n(1)
b1.n(3)
b1.n(17)
b1.n(1)
b0.jk(b1)
b1.n(255)
b1.n(218)
b1.M(12)
b1.n(3)
b1.n(1)
b1.n(0)
b1.n(2)
b1.n(17)
b1.n(3)
b1.n(17)
b1.n(0)
b1.n(63)
b1.n(0)
b0.CW=0
b0.cx=7
q=b2.aw()
p=s*4
for(s=b0.as,o=b0.c,n=b0.at,m=b0.d,l=b0.ax,k=q.length,j=b0.ay,i=0,h=0,g=0,f=0;f<r;){for(e=f+1,d=p*f,c=0;c<p;){b=d+c
for(a=0;a<64;++a){a0=a>>>3
a1=(a&7)*4
a2=b+a0*p+a1
if(f+a0>=r)a2-=p*(e+a0-r)
a3=c+a1
if(a3>=p)a2-=a3-p+4
a4=a2+1
if(!(a2>=0&&a2<k))return A.a(q,a2)
a5=q[a2]
a2=a4+1
if(!(a4>=0&&a4<k))return A.a(q,a4)
a6=q[a4]
if(!(a2>=0&&a2<k))return A.a(q,a2)
a7=q[a2]
if(!(a5<2048))return A.a(j,a5)
a3=j[a5]
a8=a6+256
if(!(a8<2048))return A.a(j,a8)
a8=j[a8]
a9=a7+512
if(!(a9<2048))return A.a(j,a9)
s[a]=B.a.i(a3+a8+j[a9],16)-128
a9=a5+768
if(!(a9<2048))return A.a(j,a9)
a9=j[a9]
a8=a6+1024
if(!(a8<2048))return A.a(j,a8)
a8=j[a8]
a3=a7+1280
if(!(a3<2048))return A.a(j,a3)
n[a]=B.a.i(a9+a8+j[a3],16)-128
a3=a5+1280
if(!(a3<2048))return A.a(j,a3)
a3=j[a3]
a8=a6+1536
if(!(a8<2048))return A.a(j,a8)
a8=j[a8]
a9=a7+1792
if(!(a9<2048))return A.a(j,a9)
l[a]=B.a.i(a3+a8+j[a9],16)-128}a3=b0.e
a8=b0.r
a8===$&&A.c("YAC_HT")
i=b0.cV(b1,s,o,i,a3,a8)
a8=b0.f
a3=b0.w
a3===$&&A.c("UVAC_HT")
h=b0.cV(b1,n,m,h,a8,a3)
g=b0.cV(b1,l,m,g,b0.f,b0.w)
c+=32}f+=8}s=b0.cx
if(s>=0){++s
b0.aI(b1,A.b([B.a.D(1,s)-1,s],t.t))}b1.n(255)
b1.n(217)
return A.z(b1.c.buffer,0,b1.a)},
i8(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=this
for(s=d.a,r=0;r<64;++r){q=B.c.cn((B.dP[r]*a+50)/100)
if(q<1)q=1
else if(q>255)q=255
p=B.x[r]
if(!(p<64))return A.a(s,p)
s[p]=q}for(p=d.b,o=0;o<64;++o){n=B.c.cn((B.dQ[o]*a+50)/100)
if(n<1)n=1
else if(n>255)n=255
m=B.x[o]
if(!(m<64))return A.a(p,m)
p[m]=n}for(m=d.c,l=d.d,k=0,j=0;j<8;++j)for(i=0;i<8;++i){if(!(k>=0&&k<64))return A.a(B.x,k)
h=B.x[k]
if(!(h<64))return A.a(s,h)
g=s[h]
f=B.an[j]
e=B.an[i]
m[k]=1/(g*f*e*8)
l[k]=1/(p[h]*f*e*8);++k}},
c0(a,b){var s,r,q,p,o,n,m,l=t.L
l.a(a)
l.a(b)
l=t.t
s=A.b([A.b([],l)],t.iZ)
for(r=b.length,q=0,p=0,o=1;o<=16;++o){for(n=1;n<=a[o];++n){if(!(p>=0&&p<r))return A.a(b,p)
m=b[p]
if(s.length<=m)B.b.sv(s,m+1)
B.b.h(s,m,A.b([q,o],l));++p;++q}q*=2}return s},
i6(){var s,r,q,p,o,n,m,l,k,j,i
for(s=this.y,r=this.x,q=t.t,p=1,o=2,n=1;n<=15;++n){for(m=p;m<o;++m){l=32767+m
B.b.h(s,l,n)
B.b.h(r,l,A.b([m,n],q))}for(l=o-1,k=-l,j=-p;k<=j;++k){i=32767+k
B.b.h(s,i,n)
B.b.h(r,i,A.b([l+k,n],q))}p=p<<1>>>0
o=o<<1>>>0}},
i9(){var s,r
for(s=this.ay,r=0;r<256;++r){s[r]=19595*r
s[r+256]=38470*r
s[r+512]=7471*r+32768
s[r+768]=-11059*r
s[r+1024]=-21709*r
s[r+1280]=32768*r+8421375
s[r+1536]=-27439*r
s[r+1792]=-5329*r}},
hQ(d5,d6){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,d0,d1,d2,d3,d4=t.H
d4.a(d5)
d4.a(d6)
for(s=0,r=0;r<8;++r){if(!(s<64))return A.a(d5,s)
q=d5[s]
d4=s+1
if(!(d4<64))return A.a(d5,d4)
p=d5[d4]
o=s+2
if(!(o<64))return A.a(d5,o)
n=d5[o]
m=s+3
if(!(m<64))return A.a(d5,m)
l=d5[m]
k=s+4
if(!(k<64))return A.a(d5,k)
j=d5[k]
i=s+5
if(!(i<64))return A.a(d5,i)
h=d5[i]
g=s+6
if(!(g<64))return A.a(d5,g)
f=d5[g]
e=s+7
if(!(e<64))return A.a(d5,e)
d=d5[e]
c=q+d
b=q-d
a=p+f
a0=p-f
a1=n+h
a2=n-h
a3=l+j
a4=c+a3
a5=c-a3
a6=a+a1
if(!(s<64))return A.a(d5,s)
d5[s]=a4+a6
if(!(k<64))return A.a(d5,k)
d5[k]=a4-a6
a7=(a-a1+a5)*0.707106781
if(!(o<64))return A.a(d5,o)
d5[o]=a5+a7
if(!(g<64))return A.a(d5,g)
d5[g]=a5-a7
a4=l-j+a2
a8=a0+b
a9=(a4-a8)*0.382683433
b0=0.5411961*a4+a9
b1=1.306562965*a8+a9
b2=(a2+a0)*0.707106781
b3=b+b2
b4=b-b2
if(!(i<64))return A.a(d5,i)
d5[i]=b4+b0
if(!(m<64))return A.a(d5,m)
d5[m]=b4-b0
if(!(d4<64))return A.a(d5,d4)
d5[d4]=b3+b1
if(!(e<64))return A.a(d5,e)
d5[e]=b3-b1
s+=8}for(s=0,r=0;r<8;++r){if(!(s<64))return A.a(d5,s)
q=d5[s]
d4=s+8
if(!(d4<64))return A.a(d5,d4)
p=d5[d4]
o=s+16
if(!(o<64))return A.a(d5,o)
n=d5[o]
m=s+24
if(!(m<64))return A.a(d5,m)
l=d5[m]
k=s+32
if(!(k<64))return A.a(d5,k)
j=d5[k]
i=s+40
if(!(i<64))return A.a(d5,i)
h=d5[i]
g=s+48
if(!(g<64))return A.a(d5,g)
f=d5[g]
e=s+56
if(!(e<64))return A.a(d5,e)
d=d5[e]
b5=q+d
b6=q-d
b7=p+f
b8=p-f
b9=n+h
c0=n-h
c1=l+j
c2=b5+c1
c3=b5-c1
c4=b7+b9
if(!(s<64))return A.a(d5,s)
d5[s]=c2+c4
if(!(k<64))return A.a(d5,k)
d5[k]=c2-c4
c5=(b7-b9+c3)*0.707106781
if(!(o<64))return A.a(d5,o)
d5[o]=c3+c5
if(!(g<64))return A.a(d5,g)
d5[g]=c3-c5
c2=l-j+c0
c6=b8+b6
c7=(c2-c6)*0.382683433
c8=0.5411961*c2+c7
c9=1.306562965*c6+c7
d0=(c0+b8)*0.707106781
d1=b6+d0
d2=b6-d0
if(!(i<64))return A.a(d5,i)
d5[i]=d2+c8
if(!(m<64))return A.a(d5,m)
d5[m]=d2-c8
if(!(d4<64))return A.a(d5,d4)
d5[d4]=d1+c9
if(!(e<64))return A.a(d5,e)
d5[e]=d1-c9;++s}for(d4=this.z,r=0;r<64;++r){d3=d5[r]*d6[r]
B.b.h(d4,r,d3>0?B.c.m(d3+0.5):B.c.m(d3-0.5))}return d4},
jj(a,b){var s,r,q,p=b.a
if(p==null)return
for(s=p.length,r=0;r<p.length;p.length===s||(0,A.b3)(p),++r){q=p[r]
a.n(255)
a.n(225)
a.M(q.length+2)
a.T(q)}},
jl(a){var s,r,q
a.n(255)
a.n(219)
a.M(132)
a.n(0)
for(s=this.a,r=0;r<64;++r)a.n(s[r])
a.n(1)
for(s=this.b,q=0;q<64;++q)a.n(s[q])},
jk(a){var s,r,q,p,o,n,m,l
a.n(255)
a.n(196)
a.M(418)
a.n(0)
for(s=0;s<16;){++s
a.n(B.ah[s])}for(r=0;r<=11;++r)a.n(B.G[r])
a.n(16)
for(q=0;q<16;){++q
a.n(B.aj[q])}for(p=0;p<=161;++p)a.n(B.al[p])
a.n(1)
for(o=0;o<16;){++o
a.n(B.ai[o])}for(n=0;n<=11;++n)a.n(B.G[n])
a.n(17)
for(m=0;m<16;){++m
a.n(B.ak[m])}for(l=0;l<=161;++l)a.n(B.af[l])},
cV(a,a0,a1,a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=this,b=t.H
b.a(a0)
b.a(a1)
t.h.a(a3)
t.w.a(a4)
b=a4.length
if(0>=b)return A.a(a4,0)
s=a4[0]
if(240>=b)return A.a(a4,240)
r=a4[240]
q=c.hQ(a0,a1)
for(b=c.Q,p=0;p<64;++p)B.b.h(b,B.x[p],q[p])
o=b[0]
o.toString
n=o-a2
if(n===0){if(0>=a3.length)return A.a(a3,0)
m=a3[0]
m.toString
c.aI(a,m)}else{l=32767+n
a3.toString
m=c.y
if(!(l>=0&&l<65535))return A.a(m,l)
m=m[l]
m.toString
if(!(m<a3.length))return A.a(a3,m)
m=a3[m]
m.toString
c.aI(a,m)
m=c.x[l]
m.toString
c.aI(a,m)}k=63
while(!0){if(!(k>0&&b[k]===0))break;--k}if(k===0){s.toString
c.aI(a,s)
return o}for(m=c.y,j=c.x,i=1;i<=k;){h=i
while(!0){if(!(h>=0&&h<64))return A.a(b,h)
if(!(b[h]===0&&h<=k))break;++h}g=h-i
if(g>=16){f=B.a.i(g,4)
for(e=1;e<=f;++e){r.toString
c.aI(a,r)}g&=15}d=b[h]
d.toString
l=32767+d
if(!(l>=0&&l<65535))return A.a(m,l)
d=m[l]
d.toString
d=(g<<4>>>0)+d
if(!(d<a4.length))return A.a(a4,d)
d=a4[d]
d.toString
c.aI(a,d)
d=j[l]
d.toString
c.aI(a,d)
i=h+1}if(k!==63){s.toString
c.aI(a,s)}return o},
aI(a,b){var s,r,q,p=this
t.L.a(b)
s=b.length
if(0>=s)return A.a(b,0)
r=b[0]
if(1>=s)return A.a(b,1)
q=b[1]-1
for(;q>=0;){if((r&B.a.D(1,q))>>>0!==0)p.CW=(p.CW|B.a.D(1,p.cx))>>>0;--q
if(--p.cx<0){s=p.CW
if(s===255){a.n(255)
a.n(0)}else a.n(s)
p.cx=7
p.CW=0}}},
sfJ(a){this.e=t.h.a(a)},
sfH(a){this.f=t.h.a(a)},
sfQ(a){this.r=t.w.a(a)},
sfP(a){this.w=t.w.a(a)}}
A.cZ.prototype={}
A.em.prototype={}
A.hO.prototype={
ske(a){this.x=t.k.a(a)},
skD(a){this.y=t.T.a(a)},
sjw(a){this.z=t.k.a(a)}}
A.en.prototype={}
A.c8.prototype={
bm(a){var s,r,q,p,o,n=A.l(t.L.a(a),!0,null,0).a_(8)
for(s=n.a,r=n.d,q=s.length,p=0;p<8;++p){o=r+p
if(!(o>=0&&o<q))return A.a(s,o)
if(s[o]!==B.a9[p])return!1}return!0},
aH(b1){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7=this,a8=null,a9=t.L,b0=A.l(a9.a(b1),!0,a8,0)
a7.d=b0
s=b0.a_(8)
for(b0=s.a,r=s.d,q=b0.length,p=0;p<8;++p){o=r+p
if(!(o>=0&&o<q))return A.a(b0,o)
if(b0[o]!==B.a9[p])return a8}for(b0=t.t,r=t.N,q=t.fi;!0;){o=a7.d
n=o.d-o.b
m=o.j()
l=a7.d.O(4)
switch(l){case"tEXt":if(a7.a==null)a7.a=new A.en(A.J(r,r),A.b([],q),A.b([],b0))
o=a7.d
k=o.R(m)
o.d=o.d+(k.c-k.d)
j=k.S()
for(i=j.length,p=0;p<i;++p)if(j[p]===0){h=B.a4.cl(new Uint8Array(j.subarray(0,A.aD(0,p,i))))
o=p+1
g=B.a4.cl(new Uint8Array(j.subarray(o,A.aD(o,a8,i))))
a7.a.ch.h(0,h,g)
break}a7.d.d+=4
break
case"IHDR":o=a7.d
k=o.R(m)
o.d=o.d+(k.c-k.d)
f=A.j(k,a8,0)
e=f.S()
o=new A.en(A.J(r,r),A.b([],q),A.b([],b0))
a7.a=o
o.a=f.j()
o=a7.a
o.toString
o.b=f.j()
o=a7.a
o.toString
d=f.a
c=f.d
b=f.d=c+1
a=d.length
if(!(c>=0&&c<a))return A.a(d,c)
o.d=d[c]
c=f.d=b+1
if(!(b>=0&&b<a))return A.a(d,b)
o.e=d[b]
b=f.d=c+1
if(!(c>=0&&c<a))return A.a(d,c)
c=f.d=b+1
if(!(b>=0&&b<a))return A.a(d,b)
o.r=d[b]
f.d=c+1
if(!(c>=0&&c<a))return A.a(d,c)
o.w=d[c]
if(!B.b.aB(A.b([0,2,3,4,6],b0),a7.a.e))return a8
o=a7.a
if(o.r!==0)return a8
switch(o.e){case 0:if(!B.b.aB(A.b([1,2,4,8,16],b0),a7.a.d))return a8
break
case 2:if(!B.b.aB(A.b([8,16],b0),a7.a.d))return a8
break
case 3:if(!B.b.aB(A.b([1,2,4,8],b0),a7.a.d))return a8
break
case 4:if(!B.b.aB(A.b([8,16],b0),a7.a.d))return a8
break
case 6:if(!B.b.aB(A.b([8,16],b0),a7.a.d))return a8
break}if(a7.d.j()!==A.at(a9.a(e),A.at(new A.a8(l),0)))throw A.d(A.f("Invalid "+l+" checksum"))
break
case"PLTE":o=a7.a
o.toString
d=a7.d
k=d.R(m)
d.d=d.d+(k.c-k.d)
o.ske(k.S())
if(a7.d.j()!==A.at(a9.a(a9.a(a7.a.x)),A.at(new A.a8(l),0)))throw A.d(A.f("Invalid "+l+" checksum"))
break
case"tRNS":o=a7.a
o.toString
d=a7.d
k=d.R(m)
d.d=d.d+(k.c-k.d)
o.skD(k.S())
a0=a7.d.j()
o=a7.a.y
o.toString
if(a0!==A.at(a9.a(o),A.at(new A.a8(l),0)))throw A.d(A.f("Invalid "+l+" checksum"))
break
case"IEND":a7.d.d+=4
break
case"gAMA":if(m!==4)throw A.d(A.f("Invalid gAMA chunk"))
a1=a7.d.j()
a7.d.d+=4
if(a1!==1e5)a7.a.Q=a1/1e5
break
case"IDAT":B.b.A(a7.a.db,n)
o=a7.d
d=o.d+=m
o.d=d+4
break
case"acTL":a7.a.toString
a7.d.j()
a7.a.toString
a7.d.j()
a7.d.d+=4
break
case"fcTL":a2=new A.em(A.b([],b0))
B.b.A(a7.a.cy,a2)
a7.d.j()
a2.b=a7.d.j()
a2.c=a7.d.j()
a7.d.j()
a7.d.j()
a7.d.k()
a7.d.k()
o=a7.d
d=o.a
c=o.d
b=o.d=c+1
a=d.length
if(!(c>=0&&c<a))return A.a(d,c)
c=b+1
o.d=c
if(!(b>=0&&b<a))return A.a(d,b)
o.d=c+4
break
case"fdAT":a7.d.j()
B.b.A(B.b.gk0(a7.a.cy).y,n)
o=a7.d
d=o.d+=m-4
o.d=d+4
break
case"bKGD":o=a7.a
d=o.e
if(d===3){d=a7.d
c=d.a
d=d.d++
if(!(d>=0&&d<c.length))return A.a(c,d);--m
a3=c[d]*3
o=o.x
d=o.length
if(!(a3>=0&&a3<d))return A.a(o,a3)
a4=o[a3]
c=a3+1
if(!(c<d))return A.a(o,c)
a5=o[c]
c=a3+2
if(!(c<d))return A.a(o,c)
a6=o[c]
B.c.m(B.a.p(255,0,255))
B.c.m(B.a.p(a6,0,255))
B.c.m(B.a.p(a5,0,255))
B.c.m(B.a.p(a4,0,255))}else if(d===0||d===4){a7.d.k()
m-=2}else if(d===2||d===6){a7.d.k()
a7.d.k()
a7.d.k()
m-=24}if(m>0)a7.d.d+=m
a7.d.d+=4
break
case"iCCP":o=a7.a
o.toString
o.at=a7.d.bO()
o=a7.a
o.toString
d=a7.d
c=d.a
b=d.d++
if(!(b>=0&&b<c.length))return A.a(c,b)
k=d.R(m-(o.at.length+2))
d.d=d.d+(k.c-k.d)
d=a7.a
d.toString
d.ay=k.S()
a7.d.d+=4
break
default:o=a7.d
d=o.d+=m
o.d=d+4
break}if(l==="IEND")break
o=a7.d
if(o.d>=o.c)return a8}return a7.a},
a4(a9){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6=this,a7=null,a8=a6.a
if(a8==null)return a7
s=null
p=a8.a
o=a8.b
a8=a8.cy
n=a8.length
if(n===0||a9===0){m=A.b([],t.i)
for(l=a6.a.db.length,a8=t.L,k=0,j=0;j<l;++j){n=a6.d
n===$&&A.c("_input")
i=a6.a.db
if(!(j<i.length))return A.a(i,j)
n.d=i[j]
h=n.j()
g=a6.d.O(4)
n=a6.d
f=n.R(h)
n.d=n.d+(f.c-f.d)
e=f.S()
k+=e.length
B.b.A(m,e)
if(a6.d.j()!==A.at(a8.a(e),A.at(new A.a8(g),0)))throw A.d(A.f("Invalid "+g+" checksum"))}s=new Uint8Array(k)
for(a8=m.length,d=0,c=0;c<m.length;m.length===a8||(0,A.b3)(m),++c){e=m[c]
J.kL(s,d,e)
d+=e.length}}else{if(a9>=n)throw A.d(A.f("Invalid Frame Number: "+a9))
if(!(a9<n))return A.a(a8,a9)
b=a8[a9]
p=b.b
o=b.c
m=A.b([],t.i)
for(a8=b.y,k=0,j=0;j<a8.length;++j){n=a6.d
n===$&&A.c("_input")
n.d=a8[j]
h=n.j()
a6.d.O(4)
n=a6.d
n.d+=4
f=n.R(h-4)
n.d=n.d+(f.c-f.d)
e=f.S()
k+=e.length
B.b.A(m,e)}s=new Uint8Array(k)
for(a8=m.length,d=0,c=0;c<m.length;m.length===a8||(0,A.b3)(m),++c){e=m[c]
J.kL(s,d,e)
d+=e.length}}a8=a6.a
n=a8.e
a=n===4||n===6||a8.y!=null?B.f:B.o
p.toString
o.toString
a0=A.T(p,o,a,a7,a7)
r=null
try{r=B.u.bG(A.bB(t.L.a(s),1,a7,0),!1)}catch(a1){q=A.a0(a1)
A.jM(q)
return a7}a2=A.l(r,!0,a7,0)
a6.c=a6.b=0
a8=a6.a
if(a8.z==null){a8.sjw(A.k1(256,new A.hM(),!1,t.p))
a8=a6.a
n=a8.x
if(n!=null&&a8.Q!=null)for(i=n.length,a8=a8.z,j=0;j<i;++j){a8.toString
a3=n[j]
if(!(a3<256))return A.a(a8,a3)
n[j]=a8[a3]}}a8=a6.a
a4=a8.a
a5=a8.b
a8.a=p
a8.b=o
a6.e=0
if(a8.w!==0){a8=B.a.i(p+7,3)
n=B.a.i(o+7,3)
a6.b4(a2,a0,0,0,8,8,a8,n)
a8=p+3
a6.b4(a2,a0,4,0,8,8,B.a.i(a8,3),n)
n=o+3
a6.b4(a2,a0,0,4,4,8,B.a.i(a8,2),B.a.i(n,3))
a8=p+1
a6.b4(a2,a0,2,0,4,4,B.a.i(a8,2),B.a.i(n,2))
n=o+1
a6.b4(a2,a0,0,2,2,4,B.a.i(a8,1),B.a.i(n,2))
a6.b4(a2,a0,1,0,2,2,B.a.i(p,1),B.a.i(n,1))
a6.b4(a2,a0,0,1,1,2,p,B.a.i(o,1))}else a6.iF(a2,a0)
a8=a6.a
a8.a=a4
a8.b=a5
n=a8.ay
if(n!=null)a0.z=new A.hc(a8.at,B.P,n)
a8=a8.ch
if(a8.a!==0)a0.jr(a8)
return a0},
a6(a){if(this.aH(t.L.a(a))==null)return null
return this.a4(0)},
b4(b1,b2,b3,b4,b5,b6,b7,b8){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8=this,a9=a8.a,b0=a9.e
if(b0===4)s=2
else if(b0===2)s=3
else{b0=b0===6?4:1
s=b0}a9=a9.d
a9.toString
r=s*a9
q=B.a.i(r+7,3)
p=B.a.i(r*b7+7,3)
o=A.H(p,0,!1,t.p)
n=A.b([o,o],t.S)
m=A.b([0,0,0,0],t.t)
for(a9=b2.x,b0=b2.a,l=a9.length,k=b5>1,j=b2.b,i=b5-b3,h=i<=1,g=b4,f=0,e=0;f<b8;++f,g+=b6,++a8.e){d=b1.a
c=b1.d++
if(!(c>=0&&c<d.length))return A.a(d,c)
c=d[c]
b=b1.R(p)
b1.d=b1.d+(b.c-b.d)
B.b.h(n,e,b.S())
if(!(e>=0&&e<2))return A.a(n,e)
a=n[e]
e=1-e
a8.ep(c,q,a,n[e])
a8.c=a8.b=0
d=a.length
a0=new A.a3(a,0,d,0,!0)
for(d=g*b0,a1=b3,a2=0;a2<b7;++a2,a1+=b5){a8.ef(a0,m)
a3=a8.dP(m)
c=d+a1
if(!(c>=0&&c<l))return A.a(a9,c)
a9[c]=a3
if(!h||k)for(a4=0;a4<b5;++a4)for(a5=0;a5<i;++a5){c=a1+a5
a6=g+a5
if(c<b0)a7=a6<j
else a7=!1
if(a7){c=a6*b0+c
if(!(c>=0&&c<l))return A.a(a9,c)
a9[c]=a3}}}}},
iF(a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=this,a1=a0.a,a2=a1.e
if(a2===4)s=2
else if(a2===2)s=3
else{a2=a2===6?4:1
s=a2}a2=a1.d
a2.toString
r=s*a2
q=a1.a
p=a1.b
o=B.a.i(q*r+7,3)
n=B.a.i(r+7,3)
m=A.H(o,0,!1,t.p)
l=A.b([m,m],t.S)
k=A.b([0,0,0,0],t.t)
for(a1=a4.x,a2=a1.length,j=0,i=0,h=0;j<p;++j,h=d){g=a3.a
f=a3.d++
if(!(f>=0&&f<g.length))return A.a(g,f)
f=g[f]
e=a3.R(o)
a3.d=a3.d+(e.c-e.d)
B.b.h(l,h,e.S())
if(!(h>=0&&h<2))return A.a(l,h)
d=1-h
a0.ep(f,n,l[h],l[d])
a0.c=a0.b=0
f=l[h]
g=f.length
c=new A.a3(f,0,g,0,!0)
for(b=0;b<q;++b,i=a){a0.ef(c,k)
a=i+1
g=a0.dP(k)
if(!(i>=0&&i<a2))return A.a(a1,i)
a1[i]=g}}},
ep(a,b,c,d){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=t.L
f.a(c)
f.a(d)
s=c.length
switch(a){case 0:break
case 1:for(f=J.R(c),r=b;r<s;++r){q=c.length
if(!(r<q))return A.a(c,r)
p=c[r]
o=r-b
if(!(o>=0&&o<q))return A.a(c,o)
o=c[o]
if(typeof p!=="number")return p.bq()
if(typeof o!=="number")return A.D(o)
f.h(c,r,p+o&255)}break
case 2:for(f=J.R(c),r=0;r<s;++r){if(!(r<c.length))return A.a(c,r)
q=c[r]
if(!(r<d.length))return A.a(d,r)
p=d[r]
if(typeof q!=="number")return q.bq()
if(typeof p!=="number")return A.D(p)
f.h(c,r,q+p&255)}break
case 3:for(f=J.R(c),r=0;r<s;++r){if(r<b)n=0
else{q=r-b
if(!(q>=0&&q<c.length))return A.a(c,q)
n=c[q]}if(!(r<d.length))return A.a(d,r)
m=d[r]
if(!(r<c.length))return A.a(c,r)
q=c[r]
p=B.a.i(n+m,1)
if(typeof q!=="number")return q.bq()
f.h(c,r,q+p&255)}break
case 4:for(f=J.R(c),r=0;r<s;++r){q=r<b
if(q)n=0
else{p=r-b
if(!(p>=0&&p<c.length))return A.a(c,p)
n=c[p]}p=d.length
if(!(r<p))return A.a(d,r)
m=d[r]
if(q)l=0
else{q=r-b
if(!(q>=0&&q<p))return A.a(d,q)
l=d[q]}k=n+m-l
j=Math.abs(k-n)
i=Math.abs(k-m)
h=Math.abs(k-l)
if(j<=i&&j<=h)g=n
else g=i<=h?m:l
if(!(r<c.length))return A.a(c,r)
q=c[r]
if(typeof q!=="number")return q.bq()
f.h(c,r,q+g&255)}break
default:throw A.d(A.f("Invalid filter value: "+a))}},
aq(a,b){var s,r,q,p,o,n=this
if(b===0)return 0
if(b===8)return a.t()
if(b===16)return a.k()
for(s=a.c;r=n.c,r<b;){q=a.d
if(q>=s)throw A.d(A.f("Invalid PNG data."))
p=a.a
a.d=q+1
if(!(q>=0&&q<p.length))return A.a(p,q)
n.b=B.a.D(p[q],r)
n.c=r+8}if(b===1)o=1
else if(b===2)o=3
else{if(b===4)s=15
else s=0
o=s}s=r-b
r=B.a.a5(n.b,s)
n.c=s
return(r&o)>>>0},
ef(a,b){var s,r,q=this
t.L.a(b)
s=q.a
r=s.e
switch(r){case 0:s=s.d
s.toString
B.b.h(b,0,q.aq(a,s))
return
case 2:s=s.d
s.toString
B.b.h(b,0,q.aq(a,s))
s=q.a.d
s.toString
B.b.h(b,1,q.aq(a,s))
s=q.a.d
s.toString
B.b.h(b,2,q.aq(a,s))
return
case 3:s=s.d
s.toString
B.b.h(b,0,q.aq(a,s))
return
case 4:s=s.d
s.toString
B.b.h(b,0,q.aq(a,s))
s=q.a.d
s.toString
B.b.h(b,1,q.aq(a,s))
return
case 6:s=s.d
s.toString
B.b.h(b,0,q.aq(a,s))
s=q.a.d
s.toString
B.b.h(b,1,q.aq(a,s))
s=q.a.d
s.toString
B.b.h(b,2,q.aq(a,s))
s=q.a.d
s.toString
B.b.h(b,3,q.aq(a,s))
return}throw A.d(A.f("Invalid color type: "+A.v(r)+"."))},
dP(a){var s,r,q,p,o,n,m,l,k,j,i,h,g=this
t.L.a(a)
s=g.a
r=s.e
switch(r){case 0:q=A.ar("g")
s=g.a
switch(s.d){case 1:q.b=a[0]===0?0:255
break
case 2:q.b=a[0]*85
break
case 4:q.b=a[0]<<4>>>0
break
case 8:q.b=a[0]
break
case 16:q.b=B.a.i(a[0],8)
break}s=s.z
s.toString
q.b=B.b.q(s,q.K())
s=g.a.y
if(s!=null){r=s.length
if(0>=r)return A.a(s,0)
p=s[0]
if(1>=r)return A.a(s,1)
s=s[1]
if(a[0]===((p&255)<<24|s&255)>>>0)return A.aE(q.K(),q.K(),q.K(),0)}return A.aE(q.K(),q.K(),q.K(),255)
case 2:o=A.ar("r")
q=A.ar("g")
n=A.ar("b")
s=g.a
switch(s.d){case 1:o.b=a[0]===0?0:255
q.b=a[1]===0?0:255
n.b=a[2]===0?0:255
break
case 2:o.b=a[0]*85
q.b=a[1]*85
n.b=a[2]*85
break
case 4:o.b=a[0]<<4>>>0
q.b=a[1]<<4>>>0
n.b=a[2]<<4>>>0
break
case 8:o.b=a[0]
q.b=a[1]
n.b=a[2]
break
case 16:o.b=B.a.i(a[0],8)
q.b=B.a.i(a[1],8)
n.b=B.a.i(a[2],8)
break}s=s.z
s.toString
o.b=B.b.q(s,o.K())
s=g.a.z
s.toString
q.b=B.b.q(s,q.K())
s=g.a.z
s.toString
n.b=B.b.q(s,n.K())
s=g.a.y
if(s!=null){r=s.length
if(0>=r)return A.a(s,0)
p=s[0]
if(1>=r)return A.a(s,1)
m=s[1]
if(2>=r)return A.a(s,2)
l=s[2]
if(3>=r)return A.a(s,3)
k=s[3]
if(4>=r)return A.a(s,4)
j=s[4]
if(5>=r)return A.a(s,5)
s=s[5]
if(a[0]===((p&255)<<8|m&255)&&a[1]===((l&255)<<8|k&255)&&a[2]===((j&255)<<8|s&255))return A.aE(o.K(),q.K(),n.K(),0)}return A.aE(o.K(),q.K(),n.K(),255)
case 3:r=a[0]
i=r*3
p=s.y
if(p!=null&&r<p.length){if(!(r>=0&&r<p.length))return A.a(p,r)
h=p[r]}else h=255
s=s.x
r=s.length
if(i>=r)return A.aE(255,255,255,h)
if(!(i>=0))return A.a(s,i)
o=s[i]
p=i+1
if(!(p<r))return A.a(s,p)
q=s[p]
p=i+2
if(!(p<r))return A.a(s,p)
return A.aE(o,q,s[p],h)
case 4:q=A.ar("g")
h=A.ar("a")
s=g.a
switch(s.d){case 1:q.b=a[0]===0?0:255
h.b=a[1]===0?0:255
break
case 2:q.b=a[0]*85
h.b=a[1]*85
break
case 4:q.b=a[0]<<4>>>0
h.b=a[1]<<4>>>0
break
case 8:q.b=a[0]
h.b=a[1]
break
case 16:q.b=B.a.i(a[0],8)
h.b=B.a.i(a[1],8)
break}s=s.z
s.toString
q.b=B.b.q(s,q.K())
return A.aE(q.K(),q.K(),q.K(),h.K())
case 6:o=A.ar("r")
q=A.ar("g")
n=A.ar("b")
h=A.ar("a")
s=g.a
switch(s.d){case 1:o.b=a[0]===0?0:255
q.b=a[1]===0?0:255
n.b=a[2]===0?0:255
h.b=a[3]===0?0:255
break
case 2:o.b=a[0]*85
q.b=a[1]*85
n.b=a[2]*85
h.b=a[3]*85
break
case 4:o.b=a[0]<<4>>>0
q.b=a[1]<<4>>>0
n.b=a[2]<<4>>>0
h.b=a[3]<<4>>>0
break
case 8:o.b=a[0]
q.b=a[1]
n.b=a[2]
h.b=a[3]
break
case 16:o.b=B.a.i(a[0],8)
q.b=B.a.i(a[1],8)
n.b=B.a.i(a[2],8)
h.b=B.a.i(a[3],8)
break}s=s.z
s.toString
o.b=B.b.q(s,o.K())
s=g.a.z
s.toString
q.b=B.b.q(s,q.K())
s=g.a.z
s.toString
n.b=B.b.q(s,n.K())
return A.aE(o.K(),q.K(),n.K(),h.K())}throw A.d(A.f("Invalid color type: "+A.v(r)+"."))}}
A.hM.prototype={
$1(a){return a},
$S:19}
A.hN.prototype={
ci(a){var s,r,q,p,o,n,m,l,k,j=this
j.f=j.e=a.d
j.r=a.f
j.w=a.r
j.x=a.w
if(j.ax==null){s=A.aq(!0,8192)
j.ax=s
j.a=a.c
r=a.a
j.y=r
q=a.b
j.z=q
s.T(A.b([137,80,78,71,13,10,26,10],t.t))
p=A.aq(!0,8192)
p.P(r)
p.P(q)
p.n(8)
p.n(j.a===B.o?2:6)
p.n(0)
p.n(0)
p.n(0)
s=j.ax
s.toString
j.bD(s,"IHDR",A.z(p.c.buffer,0,p.a))
j.jm(j.ax,a.z)}s=a.b
r=a.c===B.f?4:3
o=new Uint8Array(a.a*s*r+s)
j.hS(0,a,o)
n=B.a6.eH(o,j.d)
s=a.Q
if(s!=null)for(s=A.cQ(s,s.r,A.w(s).c),r=t.L;s.C();){q=s.d
m=a.Q.q(0,q)
m.toString
A.a_(m)
p=new A.eL(!0,new Uint8Array(8192))
p.T(B.a5.aY(q))
p.n(0)
p.T(B.a5.aY(m))
q=j.ax
q.toString
m=p.c.buffer
l=p.a
m=new Uint8Array(m,0,l)
r.a(m)
q.P(m.length)
q.T(new A.a8("tEXt"))
q.T(m)
q.P(A.at(m,A.at(new A.a8("tEXt"),0)))}if(j.as<=1){s=j.ax
s.toString
j.bD(s,"IDAT",n)}else{k=A.aq(!0,8192)
k.P(j.as)
k.T(n)
s=j.ax
s.toString
j.bD(s,"fdAT",A.z(k.c.buffer,0,k.a));++j.as}},
cm(){var s,r=this,q=r.ax
if(q==null)return null
r.bD(q,"IEND",A.b([],t.t))
r.as=0
q=r.ax
s=A.z(q.c.buffer,0,q.a)
r.ax=null
return s},
b7(a){var s
this.at=!1
this.ci(a)
s=this.cm()
s.toString
return s},
jm(a,b){var s,r
if(b==null)return
s=A.aq(!0,8192)
s.T(new A.a8(b.a))
s.n(0)
s.n(0)
s.T(b.jB())
r=this.ax
r.toString
this.bD(r,"iCCP",A.z(s.c.buffer,0,s.a))},
bD(a,b,c){t.L.a(c)
a.P(c.length)
a.T(new A.a8(b))
a.T(c)
a.P(A.at(c,A.at(new A.a8(b),0)))},
hS(a,b,c){var s,r,q
t.L.a(c)
for(s=b.b,r=0,q=0;q<s;++q)switch(4){case 4:r=this.hT(b,r,q,c)
break}},
c9(a,b,c){var s=a+b-c,r=s>a?s-a:a-s,q=s>b?s-b:b-s,p=s>c?s-c:c-s
if(r<=q&&r<=p)return a
else if(q<=p)return b
return c},
hT(b2,b3,b4,b5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1=this
t.L.a(b5)
s=b3+1
r=b5.length
if(!(b3<r))return A.a(b5,b3)
b5[b3]=4
for(q=b2.a,p=b2.c===B.f,o=b2.x,n=b4*q,m=o.length,l=(b4-1)*q,k=b4===0,j=!k,b3=s,i=0;i<q;++i){h=i===0
if(h)g=0
else{f=n+(i-1)
if(!(f>=0&&f<m))return A.a(o,f)
g=o[f]&255}if(h)e=0
else{f=n+(i-1)
if(!(f>=0&&f<m))return A.a(o,f)
e=o[f]>>>8&255}if(h)d=0
else{f=n+(i-1)
if(!(f>=0&&f<m))return A.a(o,f)
d=o[f]>>>16&255}if(k)c=0
else{f=l+i
if(!(f>=0&&f<m))return A.a(o,f)
c=o[f]&255}if(k)b=0
else{f=l+i
if(!(f>=0&&f<m))return A.a(o,f)
b=o[f]>>>8&255}if(k)a=0
else{f=l+i
if(!(f>=0&&f<m))return A.a(o,f)
a=o[f]>>>16&255}if(!j||h)a0=0
else{f=l+(i-1)
if(!(f>=0&&f<m))return A.a(o,f)
a0=o[f]&255}if(!j||h)a1=0
else{f=l+(i-1)
if(!(f>=0&&f<m))return A.a(o,f)
a1=o[f]>>>8&255}if(!j||h)a2=0
else{f=l+(i-1)
if(!(f>=0&&f<m))return A.a(o,f)
a2=o[f]>>>16&255}f=n+i
if(!(f>=0&&f<m))return A.a(o,f)
a3=o[f]
a4=b1.c9(g,c,a0)
a5=b1.c9(e,b,a1)
a6=b1.c9(d,a,a2)
s=b3+1
if(!(b3<r))return A.a(b5,b3)
b5[b3]=(a3&255)-a4&255
b3=s+1
if(!(s<r))return A.a(b5,s)
b5[s]=(a3>>>8&255)-a5&255
s=b3+1
if(!(b3<r))return A.a(b5,b3)
b5[b3]=(a3>>>16&255)-a6&255
if(p){if(h)a7=0
else{a3=n+(i-1)
if(!(a3>=0&&a3<m))return A.a(o,a3)
a7=o[a3]>>>24&255}if(k)a8=0
else{a3=l+i
if(!(a3>=0&&a3<m))return A.a(o,a3)
a8=o[a3]>>>24&255}if(!j||h)a9=0
else{h=l+(i-1)
if(!(h>=0&&h<m))return A.a(o,h)
a9=o[h]>>>24&255}h=o[f]
b0=b1.c9(a7,a8,a9)
b3=s+1
if(!(s<r))return A.a(b5,s)
b5[s]=(h>>>24&255)-b0&255}else b3=s}return b3}}
A.eP.prototype={
sk_(a){t.T.a(a)},
sfd(a){t.T.a(a)},
skr(a){t.T.a(a)},
sks(a){t.T.a(a)}}
A.eQ.prototype={
saJ(a){t.T.a(a)},
saO(a){t.T.a(a)}}
A.aG.prototype={}
A.eS.prototype={
saJ(a){t.T.a(a)},
saO(a){t.T.a(a)}}
A.eT.prototype={
saJ(a){t.T.a(a)},
saO(a){t.T.a(a)}}
A.eV.prototype={
saJ(a){t.T.a(a)},
saO(a){t.T.a(a)}}
A.eW.prototype={
saJ(a){t.T.a(a)},
saO(a){t.T.a(a)}}
A.d2.prototype={}
A.eU.prototype={}
A.hQ.prototype={
fC(a){var s,r,q,p,o=this
a.k()
a.k()
a.k()
a.k()
s=B.a.F(a.c-a.d,8)
if(s>0){o.e=new Uint16Array(s)
o.f=new Uint16Array(s)
o.r=new Uint16Array(s)
o.w=new Uint16Array(s)
for(r=0;r<s;++r){q=o.e
p=a.k()
if(!(r<q.length))return A.a(q,r)
q[r]=p
p=o.f
q=a.k()
if(!(r<p.length))return A.a(p,r)
p[r]=q
q=o.r
p=a.k()
if(!(r<q.length))return A.a(q,r)
q[r]=p
p=o.w
q=a.k()
if(!(r<p.length))return A.a(p,r)
p[r]=q}}}}
A.bH.prototype={
eT(a,b,c,d,e,f,g){if(e==null)e=a.k()
switch(e){case 0:d.toString
this.j3(a,b,c,d)
break
case 1:if(f==null)f=this.j0(a,c)
d.toString
this.j2(a,b,c,d,f,g)
break
default:throw A.d(A.f("Unsupported compression: "+e))}},
ko(a,b,c,d){return this.eT(a,b,c,d,null,null,0)},
j0(a,b){var s,r,q=new Uint16Array(b)
for(s=0;s<b;++s){r=a.k()
if(!(s<b))return A.a(q,s)
q[s]=r}return q},
j3(a,b,c,d){var s,r=b*c
if(d===16)r*=2
if(r>a.c-a.d){s=new Uint8Array(r)
this.c=s
B.e.ak(s,0,r,255)
return}this.c=a.a_(r).S()},
j2(a,b,c,d,e,f){var s,r,q,p,o,n,m,l=b*c
if(d===16)l*=2
s=new Uint8Array(l)
this.c=s
r=f*c
q=e.length
if(r>=q){B.e.ak(s,0,l,255)
return}for(p=0,o=0;o<c;++o,r=n){n=r+1
if(!(r>=0&&r<q))return A.a(e,r)
m=a.R(e[r])
a.d=a.d+(m.c-m.d)
this.hy(m,this.c,p)
p+=b}},
hy(a,b,c){var s,r,q,p,o,n,m,l,k
for(s=a.c,r=b.length;q=a.d,q<s;){p=a.a
o=a.d=q+1
n=p.length
if(!(q>=0&&q<n))return A.a(p,q)
q=p[q]
$.a1()[0]=q
q=$.a7()
if(0>=q.length)return A.a(q,0)
m=q[0]
if(m<0){m=1-m
a.d=o+1
if(!(o>=0&&o<n))return A.a(p,o)
q=p[o]
for(l=0;l<m;++l,c=k){k=c+1
if(!(c>=0&&c<r))return A.a(b,c)
b[c]=q}}else{++m
for(q=o,l=0;l<m;++l,q=o,c=k){k=c+1
o=q+1
a.d=o
if(!(q>=0&&q<p.length))return A.a(p,q)
q=p[q]
if(!(c>=0&&c<r))return A.a(b,c)
b[c]=q}}}}}
A.hR.prototype={
fD(a){var s,r,q=this
q.at=A.l(a,!0,null,0)
q.iI()
if(q.d!==943870035)return
s=q.at.j()
q.at.a_(s)
s=q.at.j()
q.ax=q.at.a_(s)
s=q.at.j()
q.ay=q.at.a_(s)
r=q.at
q.ch=r.a_(r.c-r.d)},
aK(){var s,r=this
if(r.d===943870035){s=r.at
s===$&&A.c("_input")
s=s==null}else s=!0
if(s)return!1
r.iZ()
r.j_()
r.j1()
r.ch=r.ay=r.ax=r.at=null
return!0},
jK(){if(!this.aK())return null
return this.ku()},
ku(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3=this,b4=b3.z
if(b4!=null)return b4
b4=A.T(b3.a,b3.b,B.f,null,null)
b3.z=b4
b4=b4.x
B.n.ak(b4,0,b4.length,0)
s=b3.z.aw()
b4=s.length
r=0
while(!0){q=b3.x
q===$&&A.c("layers")
if(!(r<q.length))break
c$0:{p=q[r]
q=p.y
q===$&&A.c("flags")
if((q&2)!==0)break c$0
q=p.w
q===$&&A.c("opacity")
o=q/255
n=p.r
q=p.cx
q===$&&A.c("layerImage")
m=q.aw()
q=p.a
q.toString
l=m.length
k=q
j=0
i=0
while(!0){q=p.f
q===$&&A.c("height")
if(!(j<q))break
q=p.a
q.toString
h=b3.a
if(typeof h!=="number")return A.D(h)
g=p.b
g.toString
f=(q+j)*h*4+g*4
q=k>=0
e=g
d=0
while(!0){h=p.e
h===$&&A.c("width")
if(!(d<h))break
c=i+1
if(!(i>=0&&i<l))return A.a(m,i)
b=m[i]
i=c+1
if(!(c>=0&&c<l))return A.a(m,c)
a=m[c]
c=i+1
if(!(i>=0&&i<l))return A.a(m,i)
a0=m[i]
i=c+1
if(!(c>=0&&c<l))return A.a(m,c)
a1=m[c]
if(e>=0){h=b3.a
if(typeof h!=="number")return A.D(h)
if(e<h)if(q){h=b3.b
if(typeof h!=="number")return A.D(h)
h=k<h}else h=!1
else h=!1}else h=!1
if(h){if(!(f>=0&&f<b4))return A.a(s,f)
a2=s[f]
h=f+1
if(!(h<b4))return A.a(s,h)
a3=s[h]
g=f+2
if(!(g<b4))return A.a(s,g)
a4=s[g]
g=f+3
if(!(g<b4))return A.a(s,g)
a5=s[g]
a6=a1/255*o
switch(n){case 1885434739:a7=a5
a8=a4
a9=a3
b0=a2
break
case 1852797549:a7=a1
a8=a0
a9=a
b0=b
break
case 1684632435:a7=a1
a8=a0
a9=a
b0=b
break
case 1684107883:b0=Math.min(a2,b)
a9=Math.min(a3,a)
a8=Math.min(a4,a0)
a7=a1
break
case 1836411936:b0=a2*b>>>8
a9=a3*a>>>8
a8=a4*a0>>>8
a7=a1
break
case 1768188278:b0=A.hS(a2,b)
a9=A.hS(a3,a)
a8=A.hS(a4,a0)
a7=a1
break
case 1818391150:b0=B.c.m(B.a.p(a2+b-255,0,255))
a9=B.c.m(B.a.p(a3+a-255,0,255))
a8=B.c.m(B.a.p(a4+a0-255,0,255))
a7=a1
break
case 1684751212:a7=a1
a8=a0
a9=a
b0=b
break
case 1818850405:b0=Math.max(a2,b)
a9=Math.max(a3,a)
a8=Math.max(a4,a0)
a7=a1
break
case 1935897198:b0=B.c.m(B.a.p(255-(255-b)*(255-a2),0,255))
a9=B.c.m(B.a.p(255-(255-a)*(255-a3),0,255))
a8=B.c.m(B.a.p(255-(255-a0)*(255-a4),0,255))
a7=a1
break
case 1684633120:b0=A.hT(a2,b)
a9=A.hT(a3,a)
a8=A.hT(a4,a0)
a7=a1
break
case 1818518631:b0=b+a2>255?255:a2+b
a9=a+a3>255?255:a3+a
a8=a0+a4>255?255:a4+a0
a7=a1
break
case 1818706796:a7=a1
a8=a0
a9=a
b0=b
break
case 1870030194:b0=A.k7(a2,b,a5,a1)
a9=A.k7(a3,a,a5,a1)
a8=A.k7(a4,a0,a5,a1)
a7=a1
break
case 1934387572:b0=A.k8(a2,b)
a9=A.k8(a3,a)
a8=A.k8(a4,a0)
a7=a1
break
case 1749838196:b0=A.k5(a2,b)
a9=A.k5(a3,a)
a8=A.k5(a4,a0)
a7=a1
break
case 1984719220:b0=A.k9(a2,b)
a9=A.k9(a3,a)
a8=A.k9(a4,a0)
a7=a1
break
case 1816947060:b0=A.k6(a2,b)
a9=A.k6(a3,a)
a8=A.k6(a4,a0)
a7=a1
break
case 1884055924:b0=b<128?Math.min(a2,2*b):Math.max(a2,2*(b-128))
a9=a<128?Math.min(a3,2*a):Math.max(a3,2*(a-128))
a8=a0<128?Math.min(a4,2*a0):Math.max(a4,2*(a0-128))
a7=a1
break
case 1749903736:b0=b<255-a2?0:255
a9=a<255-a3?0:255
a8=a0<255-a4?0:255
a7=a1
break
case 1684629094:b0=Math.abs(b-a2)
a9=Math.abs(a-a3)
a8=Math.abs(a0-a4)
a7=a1
break
case 1936553316:b0=B.c.aE(b+a2-2*b*a2/255)
a9=B.c.aE(a+a3-2*a*a3/255)
a8=B.c.aE(a0+a4-2*a0*a4/255)
a7=a1
break
case 1718842722:a7=a1
a8=a0
a9=a
b0=b
break
case 1717856630:a7=a1
a8=a0
a9=a
b0=b
break
case 1752524064:a7=a1
a8=a0
a9=a
b0=b
break
case 1935766560:a7=a1
a8=a0
a9=a
b0=b
break
case 1668246642:a7=a1
a8=a0
a9=a
b0=b
break
case 1819634976:a7=a1
a8=a0
a9=a
b0=b
break
default:a7=a1
a8=a0
a9=a
b0=b}g=1-a6
b0=B.c.m(a2*g+b0*a6)
a9=B.c.m(a3*g+a9*a6)
a8=B.c.m(a4*g+a8*a6)
a7=B.c.m(a5*g+a7*a6)
s[f]=b0
b1=h+1
s[h]=a9
b2=b1+1
if(!(b1<b4))return A.a(s,b1)
s[b1]=a8
if(!(b2<b4))return A.a(s,b2)
s[b2]=a7}f+=4;++d;++e}++j;++k}}++r}b4=b3.z
b4.toString
return b4},
iI(){var s,r,q,p,o,n=this,m=n.at
m===$&&A.c("_input")
n.d=m.j()
m=n.at.k()
n.e=m
if(m!==1){n.d=0
return}s=n.at.a_(6)
for(m=s.a,r=s.d,q=m.length,p=0;p<6;++p){o=r+p
if(!(o>=0&&o<q))return A.a(m,o)
if(m[o]!==0){n.d=0
return}}n.f=n.at.k()
n.b=n.at.j()
n.a=n.at.j()
n.r=n.at.k()
n.w=n.at.k()},
iZ(){var s,r,q,p,o,n,m,l=this,k=l.ax
k===$&&A.c("_imageResourceData")
k.d=k.b
for(k=l.Q;s=l.ax,s.d<s.c;){r=s.j()
q=l.ax.k()
s=l.ax
p=s.a
o=s.d++
if(!(o>=0&&o<p.length))return A.a(p,o)
o=p[o]
s.O(o)
if((o&1)===0)++l.ax.d
n=l.ax.j()
s=l.ax
m=s.R(n)
s.d=s.d+(m.c-m.d)
if((n&1)===1)++l.ax.d
if(r===943868237)k.h(0,q,new A.eR())}},
j_(){var s,r,q,p,o,n,m,l,k,j,i=this,h=i.ay
h===$&&A.c("_layerAndMaskData")
h.d=h.b
s=h.j()
if((s&1)!==0)++s
r=i.ay.a_(s)
h=t.k9
i.sfV(t.f0.a(A.b([],h)))
if(s>0){q=r.k()
$.a6()[0]=q
q=$.ag()
if(0>=q.length)return A.a(q,0)
p=q[0]
if(p<0)p=-p
for(q=t.N,o=t.mi,n=t.na,m=0;m<p;++m){l=new A.d1(A.J(q,o),A.b([],h),A.b([],n))
l.fE(r)
k=i.x
k===$&&A.c("layers")
B.b.A(k,l)}}m=0
while(!0){h=i.x
h===$&&A.c("layers")
if(!(m<h.length))break
h[m].kl(r,i);++m}s=i.ay.j()
j=i.ay.a_(s)
if(s>0){j.k()
j.k()
j.k()
j.k()
j.k()
j.k()
j.t()}},
j1(){var s,r,q,p,o,n,m,l,k=this,j="channels",i="mergeImageChannels",h=k.ch
h===$&&A.c("_imageData")
h.d=h.b
s=h.k()
if(s===1){h=k.b
r=k.f
r===$&&A.c(j)
if(typeof h!=="number")return h.ap()
q=h*r
p=new Uint16Array(q)
for(o=0;o<q;++o)p[o]=k.ch.k()}else p=null
k.sfW(t.I.a(A.b([],t.mS)))
o=0
while(!0){h=k.f
h===$&&A.c(j)
if(!(o<h))break
h=k.y
h===$&&A.c(i)
r=k.ch
r.toString
n=o===3?-1:o
n=new A.bH(n)
n.eT(r,k.a,k.b,k.r,s,p,o)
B.b.A(h,n);++o}h=k.w
r=k.r
n=k.a
m=k.b
l=k.y
l===$&&A.c(i)
k.z=A.lv(h,r,n,m,l)},
sfV(a){this.x=t.f0.a(a)},
sfW(a){this.y=t.I.a(a)}}
A.eR.prototype={}
A.d1.prototype={
fE(a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4=this,a5=a7.j(),a6=$.A()
a6[0]=a5
a5=$.P()
if(0>=a5.length)return A.a(a5,0)
a4.a=a5[0]
a6[0]=a7.j()
a4.b=a5[0]
a6[0]=a7.j()
a4.c=a5[0]
a6[0]=a7.j()
a5=a5[0]
a4.d=a5
a6=a4.b
a6.toString
a4.e=a5-a6
a6=a4.c
a5=a4.a
a5.toString
a4.f=a6-a5
a4.sfX(t.I.a(A.b([],t.mS)))
s=a7.k()
for(r=0;r<s;++r){a5=a7.k()
$.a6()[0]=a5
a5=$.ag()
if(0>=a5.length)return A.a(a5,0)
q=a5[0]
a7.j()
a5=a4.as
a5===$&&A.c("channels")
B.b.A(a5,new A.bH(q))}p=a7.j()
if(p!==943868237)throw A.d(A.f("Invalid PSD layer signature: "+B.a.bo(p,16)))
a4.r=a7.j()
a4.w=a7.t()
a7.t()
a4.y=a7.t()
if(a7.t()!==0)throw A.d(A.f("Invalid PSD layer data"))
o=a7.j()
n=a7.a_(o)
if(o>0){o=n.j()
if(o>0){m=n.a_(o)
a5=m.d
m.j()
m.j()
m.j()
m.j()
m.t()
m.t()
if(m.c-a5===20)m.d+=2
else{m.t()
m.t()
m.j()
m.j()
m.j()
m.j()}}o=n.j()
if(o>0)new A.hQ().fC(n.a_(o))
o=n.t()
n.O(o)
l=4-B.a.I(o,4)-1
if(l>0)n.d+=l
for(a5=n.c,a6=a4.ay,k=a4.cy,j=t.t,i=t.dM;n.d<a5;){p=n.j()
if(p!==943868237)throw A.d(A.f("PSD invalid signature for layer additional data: "+B.a.bo(p,16)))
h=n.O(4)
o=n.j()
g=n.R(o)
f=n.d+(g.c-g.d)
n.d=f
if((o&1)===1)n.d=f+1
a6.h(0,h,A.nT(h,g))
if(h==="lrFX"){e=A.j(i.a(a6.q(0,"lrFX")).b,null,0)
e.k()
d=e.k()
for(c=0;c<d;++c){e.O(4)
b=e.O(4)
a=e.j()
if(b==="dsdw"){a0=new A.eQ()
B.b.A(k,a0)
a0.a=e.j()
e.j()
e.j()
e.j()
e.j()
a0.saJ(A.b([e.k(),e.k(),e.k(),e.k(),e.k()],j))
e.O(8)
f=e.a
a1=e.d
a2=e.d=a1+1
a3=f.length
if(!(a1>=0&&a1<a3))return A.a(f,a1)
a1=e.d=a2+1
if(!(a2>=0&&a2<a3))return A.a(f,a2)
e.d=a1+1
if(!(a1>=0&&a1<a3))return A.a(f,a1)
a0.saO(A.b([e.k(),e.k(),e.k(),e.k(),e.k()],j))}else if(b==="isdw"){a0=new A.eT()
B.b.A(k,a0)
a0.a=e.j()
e.j()
e.j()
e.j()
e.j()
a0.saJ(A.b([e.k(),e.k(),e.k(),e.k(),e.k()],j))
e.O(8)
f=e.a
a1=e.d
a2=e.d=a1+1
a3=f.length
if(!(a1>=0&&a1<a3))return A.a(f,a1)
a1=e.d=a2+1
if(!(a2>=0&&a2<a3))return A.a(f,a2)
e.d=a1+1
if(!(a1>=0&&a1<a3))return A.a(f,a1)
a0.saO(A.b([e.k(),e.k(),e.k(),e.k(),e.k()],j))}else if(b==="oglw"){a0=new A.eV()
B.b.A(k,a0)
a0.a=e.j()
e.j()
e.j()
a0.saJ(A.b([e.k(),e.k(),e.k(),e.k(),e.k()],j))
e.O(8)
f=e.a
a1=e.d
a2=e.d=a1+1
a3=f.length
if(!(a1>=0&&a1<a3))return A.a(f,a1)
e.d=a2+1
if(!(a2>=0&&a2<a3))return A.a(f,a2)
if(a0.a===2)a0.saO(A.b([e.k(),e.k(),e.k(),e.k(),e.k()],j))}else if(b==="iglw"){a0=new A.eS()
B.b.A(k,a0)
a0.a=e.j()
e.j()
e.j()
a0.saJ(A.b([e.k(),e.k(),e.k(),e.k(),e.k()],j))
e.O(8)
f=e.a
a1=e.d
a2=e.d=a1+1
a3=f.length
if(!(a1>=0&&a1<a3))return A.a(f,a1)
a1=e.d=a2+1
if(!(a2>=0&&a2<a3))return A.a(f,a2)
if(a0.a===2){e.d=a1+1
if(!(a1>=0&&a1<a3))return A.a(f,a1)
a0.saO(A.b([e.k(),e.k(),e.k(),e.k(),e.k()],j))}}else if(b==="bevl"){a0=new A.eP()
B.b.A(k,a0)
a0.a=e.j()
e.j()
e.j()
e.j()
e.O(8)
e.O(8)
a0.sk_(A.b([e.k(),e.k(),e.k(),e.k(),e.k()],j))
a0.sfd(A.b([e.k(),e.k(),e.k(),e.k(),e.k()],j))
f=e.a
a1=e.d
a2=e.d=a1+1
a3=f.length
if(!(a1>=0&&a1<a3))return A.a(f,a1)
a1=e.d=a2+1
if(!(a2>=0&&a2<a3))return A.a(f,a2)
a2=e.d=a1+1
if(!(a1>=0&&a1<a3))return A.a(f,a1)
a1=e.d=a2+1
if(!(a2>=0&&a2<a3))return A.a(f,a2)
a2=e.d=a1+1
if(!(a1>=0&&a1<a3))return A.a(f,a1)
e.d=a2+1
if(!(a2>=0&&a2<a3))return A.a(f,a2)
if(a0.a===2){a0.skr(A.b([e.k(),e.k(),e.k(),e.k(),e.k()],j))
a0.sks(A.b([e.k(),e.k(),e.k(),e.k(),e.k()],j))}}else if(b==="sofi"){a0=new A.eW()
B.b.A(k,a0)
a0.a=e.j()
e.O(4)
a0.saJ(A.b([e.k(),e.k(),e.k(),e.k(),e.k()],j))
f=e.a
a1=e.d
a2=e.d=a1+1
a3=f.length
if(!(a1>=0&&a1<a3))return A.a(f,a1)
e.d=a2+1
if(!(a2>=0&&a2<a3))return A.a(f,a2)
a0.saO(A.b([e.k(),e.k(),e.k(),e.k(),e.k()],j))}else e.d+=a}}}}},
kl(a,b){var s,r,q,p,o,n=this,m=0
while(!0){s=n.as
s===$&&A.c("channels")
if(!(m<s.length))break
s=s[m]
r=n.e
r===$&&A.c("width")
q=n.f
q===$&&A.c("height")
s.ko(a,r,q,b.r);++m}r=b.w
q=b.r
p=n.e
p===$&&A.c("width")
o=n.f
o===$&&A.c("height")
n.cx=A.lv(r,q,p,o,s)},
sfX(a){this.as=t.I.a(a)}}
A.c9.prototype={}
A.d0.prototype={
a6(a){this.a=A.lu(t.L.a(a))
return this.a4(0)},
a4(a){var s=this.a
if(s==null)return null
return s.jK()}}
A.i1.prototype={}
A.d8.prototype={
bm(a){var s=A.l(t.L.a(a),!0,null,0).a_(18),r=s.a,q=s.d,p=q+2,o=r.length
if(!(p>=0&&p<o))return A.a(r,p)
if(r[p]!==2)return!1
q+=16
if(!(q>=0&&q<o))return A.a(r,q)
q=r[q]
if(q!==24&&q!==32)return!1
return!0},
aH(a){var s,r,q,p,o,n,m,l,k=this
t.L.a(a)
k.a=new A.i1()
s=A.l(a,!0,null,0)
k.b=s
r=s.a_(18)
s=r.a
q=r.d
p=q+2
o=s.length
if(!(p>=0&&p<o))return A.a(s,p)
if(s[p]!==2)return null
p=q+16
if(!(p>=0&&p<o))return A.a(s,p)
p=s[p]
if(p!==24&&p!==32)return null
n=k.a
n.toString
m=q+12
if(!(m>=0&&m<o))return A.a(s,m)
m=s[m]
l=q+13
if(!(l>=0&&l<o))return A.a(s,l)
n.a=m&255|(s[l]&255)<<8
l=q+14
if(!(l>=0&&l<o))return A.a(s,l)
l=s[l]
q+=15
if(!(q>=0&&q<o))return A.a(s,q)
n.b=l&255|(s[q]&255)<<8
n.d=k.b.d
n.e=p
return n},
a4(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=this,d=e.a
if(d==null)return null
s=e.b
s===$&&A.c("input")
r=d.d
r.toString
s.d=r
q=A.T(d.a,d.b,B.o,null,null)
for(p=q.b-1,d=q.a,s=q.x,r=s.length;p>=0;--p)for(o=p*d,n=0;n<d;++n){m=e.b
l=m.a
k=m.d
j=m.d=k+1
i=l.length
if(!(k>=0&&k<i))return A.a(l,k)
k=l[k]
h=m.d=j+1
if(!(j>=0&&j<i))return A.a(l,j)
j=l[j]
g=m.d=h+1
if(!(h>=0&&h<i))return A.a(l,h)
h=l[h]
if(e.a.e===32){m.d=g+1
if(!(g>=0&&g<i))return A.a(l,g)
f=l[g]}else f=255
m=B.c.m(B.a.p(f,0,255))
k=B.c.m(B.a.p(k,0,255))
j=B.c.m(B.a.p(j,0,255))
h=B.c.m(B.a.p(h,0,255))
l=o+n
if(!(l>=0&&l<r))return A.a(s,l)
s[l]=(m<<24|k<<16|j<<8|h)>>>0}return q},
a6(a){if(this.aH(t.L.a(a))==null)return null
return this.a4(0)}}
A.i0.prototype={
b7(a){var s,r,q,p,o,n,m,l,k,j=A.aq(!0,8192),i=A.H(18,0,!1,t.p)
B.b.h(i,2,2)
s=a.a
B.b.h(i,12,s&255)
B.b.h(i,13,B.a.i(s,8)&255)
r=a.b
B.b.h(i,14,r&255)
B.b.h(i,15,B.a.i(r,8)&255)
q=a.c
B.b.h(i,16,q===B.o?24:32)
j.T(i)
for(p=r-1,r=q===B.f,q=a.x,o=q.length;p>=0;--p)for(n=p*s,m=0;m<s;++m){l=n+m
if(!(l>=0&&l<o))return A.a(q,l)
k=q[l]
j.n(k>>>16&255)
j.n(k>>>8&255)
j.n(k&255)
if(r)j.n(k>>>24&255)}return A.z(j.c.buffer,0,j.a)}}
A.i2.prototype={
N(a){var s,r,q,p,o,n=this
if(a===0)return 0
if(n.c===0){n.c=8
n.b=n.a.t()}for(s=n.a,r=0;q=n.c,a>q;){p=B.a.D(r,q)
o=n.b
if(!(q>=0&&q<9))return A.a(B.j,q)
r=p+(o&B.j[q])
a-=q
n.c=8
q=s.a
o=s.d++
if(!(o>=0&&o<q.length))return A.a(q,o)
n.b=q[o]}if(a>0){if(q===0){n.c=8
n.b=s.t()}s=B.a.D(r,a)
q=n.b
p=n.c-a
q=B.a.a8(q,p)
if(!(a<9))return A.a(B.j,a)
r=s+(q&B.j[a])
n.c=p}return r}}
A.f5.prototype={
u(a){var s=this,r=s.a
if(B.aK.a3(r))return A.v(B.aK.q(0,r))+": "+s.b+" "+s.c
return"<"+r+">: "+s.b+" "+s.c},
kq(){var s=this.d
s.toString
this.e.d=s
return this.aA()},
d8(){var s,r,q=this,p=q.d
p.toString
q.e.d=p
s=A.b([],t.t)
for(p=q.c,r=0;r<p;++r)B.b.A(s,q.aA())
return s},
aA(){var s,r,q,p=this
switch(p.b){case 1:case 2:return p.e.t()
case 3:return p.e.k()
case 4:return p.e.j()
case 5:s=p.e
r=s.j()
q=s.j()
if(q===0)return 0
return B.a.V(r,q)
case 6:throw A.d(A.f("Unhandled value type: SBYTE"))
case 7:return p.e.t()
case 8:throw A.d(A.f("Unhandled value type: SSHORT"))
case 9:throw A.d(A.f("Unhandled value type: SLONG"))
case 10:throw A.d(A.f("Unhandled value type: SRATIONAL"))
case 11:throw A.d(A.f("Unhandled value type: FLOAT"))
case 12:throw A.d(A.f("Unhandled value type: DOUBLE"))}return 0}}
A.i3.prototype={
jH(a,b,c,d){var s,r,q,p=this
p.r=b
p.x=p.w=0
s=B.a.F(p.a+7,8)
for(r=0,q=0;q<d;++q){p.cF(a,r,c)
r+=s}},
cF(a,b,c){var s,r,q,p,o,n,m,l=this
l.d=0
for(s=l.a,r=!0;c<s;){for(;r;){q=l.aW(10)
if(!(q<1024))return A.a(B.H,q)
p=B.H[q]
o=B.a.i(p,1)&15
if(o===12){q=(q<<2&12|l.aa(2))>>>0
if(!(q<16))return A.a(B.l,q)
p=B.l[q]
n=B.a.i(p,1)
c+=B.a.i(p,4)&4095
l.a2(4-(n&7))}else if(o===0)throw A.d(A.f("TIFFFaxDecoder0"))
else if(o===15)throw A.d(A.f("TIFFFaxDecoder1"))
else{c+=B.a.i(p,5)&2047
l.a2(10-o)
if((p&1)===0){B.b.h(l.f,l.d++,c)
r=!1}}}if(c===s){if(l.z===2)if(l.w!==0){s=l.x
s.toString
l.x=s+1
l.w=0}break}for(;!r;){q=l.aa(4)
if(!(q<16))return A.a(B.A,q)
p=B.A[q]
m=p>>>5&2047
if(m===100){q=l.aW(9)
if(!(q<512))return A.a(B.K,q)
p=B.K[q]
o=B.a.i(p,1)&15
m=B.a.i(p,5)&2047
if(o===12){l.a2(5)
q=l.aa(4)
if(!(q<16))return A.a(B.l,q)
p=B.l[q]
n=B.a.i(p,1)
m=B.a.i(p,4)&4095
l.ad(a,b,c,m)
c+=m
l.a2(4-(n&7))}else if(o===15)throw A.d(A.f("TIFFFaxDecoder2"))
else{l.ad(a,b,c,m)
c+=m
l.a2(9-o)
if((p&1)===0){B.b.h(l.f,l.d++,c)
r=!0}}}else{if(m===200){q=l.aa(2)
if(!(q<4))return A.a(B.z,q)
p=B.z[q]
m=p>>>5&2047
l.ad(a,b,c,m)
c+=m
l.a2(2-(p>>>1&15))
B.b.h(l.f,l.d++,c)}else{l.ad(a,b,c,m)
c+=m
l.a2(4-(p>>>1&15))
B.b.h(l.f,l.d++,c)}r=!0}}if(c===s){if(l.z===2)if(l.w!==0){s=l.x
s.toString
l.x=s+1
l.w=0}break}}B.b.h(l.f,l.d++,c)},
jI(a1,a2,a3,a4,a5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=this
a0.r=a2
a0.z=3
a0.x=a0.w=0
s=a0.a
r=B.a.F(s+7,8)
q=A.H(2,null,!1,t.x)
a0.at=a5&1
a0.as=a5>>>2&1
if(a0.ed()!==1)throw A.d(A.f("TIFFFaxDecoder3"))
a0.cF(a1,0,a3)
for(p=r,o=1;o<a4;++o){if(a0.ed()===0){n=a0.e
a0.sd6(a0.f)
a0.sd4(n)
a0.y=0
m=a3
l=-1
k=!0
j=0
while(!0){m.toString
if(!(m<s))break
a0.dU(l,k,q)
i=q[0]
h=q[1]
g=a0.aa(7)
if(!(g<128))return A.a(B.B,g)
g=B.B[g]&255
f=g>>>3&15
e=g&7
if(f===0){if(!k){h.toString
a0.ad(a1,p,m,h-m)}a0.a2(7-e)
m=h
l=m}else if(f===1){a0.a2(7-e)
d=j+1
c=d+1
if(k){m+=a0.c2()
B.b.h(a0.f,j,m)
b=a0.c1()
a0.ad(a1,p,m,b)
m+=b
B.b.h(a0.f,d,m)}else{b=a0.c1()
a0.ad(a1,p,m,b)
m+=b
B.b.h(a0.f,j,m)
m+=a0.c2()
B.b.h(a0.f,d,m)}j=c
l=m}else{if(f<=8){i.toString
a=i+(f-5)
d=j+1
B.b.h(a0.f,j,a)
k=!k
if(k)a0.ad(a1,p,m,a-m)
a0.a2(7-e)}else throw A.d(A.f("TIFFFaxDecoder4"))
m=a
j=d
l=m}}B.b.h(a0.f,j,m)
a0.d=j+1}else a0.cF(a1,p,a3)
p+=r}},
jM(a4,a5,a6,a7,a8){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3=this
a3.r=a5
a3.z=4
a3.x=a3.w=0
s=a3.a
r=B.a.F(s+7,8)
q=A.H(2,null,!1,t.x)
p=a3.f
a3.d=0
a3.d=1
B.b.h(p,0,s)
B.b.h(p,a3.d++,s)
for(o=0,n=0;n<a7;++n){m=a3.e
a3.sd6(a3.f)
a3.sd4(m)
a3.y=0
l=a6
k=-1
j=!0
i=0
while(!0){l.toString
if(!(l<s))break
a3.dU(k,j,q)
h=q[0]
g=q[1]
f=a3.aa(7)
if(!(f<128))return A.a(B.B,f)
f=B.B[f]&255
e=f>>>3&15
d=f&7
if(e===0){if(!j){g.toString
a3.ad(a4,o,l,g-l)}a3.a2(7-d)
l=g
k=l}else if(e===1){a3.a2(7-d)
c=i+1
b=c+1
if(j){l+=a3.c2()
B.b.h(m,i,l)
a=a3.c1()
a3.ad(a4,o,l,a)
l+=a
B.b.h(m,c,l)}else{a=a3.c1()
a3.ad(a4,o,l,a)
l+=a
B.b.h(m,i,l)
l+=a3.c2()
B.b.h(m,c,l)}i=b
k=l}else if(e<=8){h.toString
a0=h+(e-5)
c=i+1
B.b.h(m,i,a0)
j=!j
if(j)a3.ad(a4,o,l,a0-l)
a3.a2(7-d)
l=a0
i=c
k=l}else if(e===11){if(a3.aa(3)!==7)throw A.d(A.f("TIFFFaxDecoder5"))
for(a1=0,a2=!1;!a2;){for(;a3.aa(1)!==1;)++a1
if(a1>5){a1-=6
if(!j&&a1>0){c=i+1
B.b.h(m,i,l)
i=c}l+=a1
if(a1>0)j=!0
if(a3.aa(1)===0){if(!j){c=i+1
B.b.h(m,i,l)
i=c}j=!0}else{if(j){c=i+1
B.b.h(m,i,l)
i=c}j=!1}a2=!0}if(a1===5){if(!j){c=i+1
B.b.h(m,i,l)
i=c}l+=a1
j=!0}else{l+=a1
c=i+1
B.b.h(m,i,l)
a3.ad(a4,o,l,1);++l
i=c
j=!1}}}else throw A.d(A.f("TIFFFaxDecoder5 "+e))}B.b.h(m,i,l)
a3.d=i+1
o+=r}},
c2(){var s,r,q,p,o,n,m=this
for(s=0,r=!0;r;){q=m.aW(10)
if(!(q<1024))return A.a(B.H,q)
p=B.H[q]
o=B.a.i(p,1)&15
if(o===12){q=(q<<2&12|m.aa(2))>>>0
if(!(q<16))return A.a(B.l,q)
p=B.l[q]
n=B.a.i(p,1)
s+=B.a.i(p,4)&4095
m.a2(4-(n&7))}else if(o===0)throw A.d(A.f("TIFFFaxDecoder0"))
else if(o===15)throw A.d(A.f("TIFFFaxDecoder1"))
else{s+=B.a.i(p,5)&2047
m.a2(10-o)
if((p&1)===0)r=!1}}return s},
c1(){var s,r,q,p,o,n,m,l=this
for(s=0,r=!1;!r;){q=l.aa(4)
if(!(q<16))return A.a(B.A,q)
p=B.A[q]
o=p>>>5&2047
if(o===100){q=l.aW(9)
if(!(q<512))return A.a(B.K,q)
p=B.K[q]
n=B.a.i(p,1)&15
m=B.a.i(p,5)
if(n===12){l.a2(5)
q=l.aa(4)
if(!(q<16))return A.a(B.l,q)
p=B.l[q]
m=B.a.i(p,1)
s+=B.a.i(p,4)&4095
l.a2(4-(m&7))}else if(n===15)throw A.d(A.f("TIFFFaxDecoder2"))
else{s+=m&2047
l.a2(9-n)
if((p&1)===0)r=!0}}else{if(o===200){q=l.aa(2)
if(!(q<4))return A.a(B.z,q)
p=B.z[q]
s+=p>>>5&2047
l.a2(2-(p>>>1&15))}else{s+=o
l.a2(4-(p>>>1&15))}r=!0}}return s},
ed(){var s,r,q=this,p="TIFFFaxDecoder8",o=q.as
if(o===0){if(q.aW(12)!==1)throw A.d(A.f("TIFFFaxDecoder6"))}else if(o===1){o=q.w
o.toString
s=8-o
if(q.aW(s)!==0)throw A.d(A.f(p))
if(s<4)if(q.aW(8)!==0)throw A.d(A.f(p))
for(;r=q.aW(8),r!==1;)if(r!==0)throw A.d(A.f(p))}if(q.at===0)return 1
else return q.aa(1)},
dU(a,b,c){var s,r,q,p,o,n,m=this
t.dW.a(c)
s=m.e
r=m.d
q=m.y
p=q>0?q-1:0
p=b?(p&4294967294)>>>0:(p|1)>>>0
for(q=s.length,o=p;o<r;o+=2){if(!(o<q))return A.a(s,o)
n=s[o]
n.toString
a.toString
if(n>a){m.y=o
B.b.h(c,0,n)
break}}n=o+1
if(n<r){if(!(n<q))return A.a(s,n)
B.b.h(c,1,s[n])}},
ad(a,b,c,d){var s,r,q,p,o,n=8*b+A.o(c),m=n+d,l=B.a.i(n,3),k=n&7
if(k>0){s=B.a.D(1,7-k)
r=a.a
q=a.d+l
if(!(q>=0&&q<r.length))return A.a(r,q)
p=r[q]
while(!0){if(!(s>0&&n<m))break
p=(p|s)>>>0
s=s>>>1;++n}a.h(0,l,p)}l=B.a.i(n,3)
for(r=m-7;n<r;l=o){o=l+1
J.n(a.a,a.d+l,255)
n+=8}for(;n<m;){l=B.a.i(n,3)
r=a.a
q=a.d+l
if(!(q>=0&&q<r.length))return A.a(r,q)
J.n(r,q,(r[q]|B.a.D(1,7-(n&7)))>>>0);++n}},
aW(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=this,c=d.r
c===$&&A.c("data")
s=c.d
r=c.c-s-1
q=d.x
p=d.c
if(p===1){q.toString
c=c.a
p=s+q
o=c.length
if(!(p>=0&&p<o))return A.a(c,p)
n=c[p]
if(q===r){m=0
l=0}else{p=q+1
k=s+p
if(p===r){if(!(k>=0&&k<o))return A.a(c,k)
m=c[k]
l=0}else{if(!(k>=0&&k<o))return A.a(c,k)
m=c[k]
s+=q+2
if(!(s>=0&&s<o))return A.a(c,s)
l=c[s]}}}else if(p===2){q.toString
c=c.a
p=s+q
o=c.length
if(!(p>=0&&p<o))return A.a(c,p)
n=B.q[c[p]&255]
if(q===r){m=0
l=0}else{p=q+1
k=s+p
if(p===r){if(!(k>=0&&k<o))return A.a(c,k)
m=B.q[c[k]&255]
l=0}else{if(!(k>=0&&k<o))return A.a(c,k)
m=B.q[c[k]&255]
s+=q+2
if(!(s>=0&&s<o))return A.a(c,s)
l=B.q[c[s]&255]}}}else throw A.d(A.f("TIFFFaxDecoder7"))
c=d.w
c.toString
j=8-c
i=a-j
if(i>8){h=i-8
g=8}else{g=i
h=0}q.toString
c=d.x=q+1
if(!(j>=0&&j<9))return A.a(B.j,j)
f=B.a.D(n&B.j[j],i)
if(!(g>=0))return A.a(B.r,g)
e=B.a.a5(m&B.r[g],8-g)
if(h!==0){e=B.a.D(e,h)
if(!(h<9))return A.a(B.r,h)
e|=B.a.a5(l&B.r[h],8-h)
d.x=c+1
d.w=h}else if(g===8){d.w=0
d.x=c+1}else d.w=g
return(f|e)>>>0},
aa(a){var s,r,q,p,o,n,m,l,k,j,i,h=this,g=h.r
g===$&&A.c("data")
s=g.d
r=g.c-s-1
q=h.x
p=h.c
if(p===1){q.toString
g=g.a
p=s+q
o=g.length
if(!(p>=0&&p<o))return A.a(g,p)
n=g[p]
if(q===r)m=0
else{s+=q+1
if(!(s>=0&&s<o))return A.a(g,s)
m=g[s]}}else if(p===2){q.toString
g=g.a
p=s+q
o=g.length
if(!(p>=0&&p<o))return A.a(g,p)
n=B.q[g[p]&255]
if(q===r)m=0
else{s+=q+1
if(!(s>=0&&s<o))return A.a(g,s)
m=B.q[g[s]&255]}}else throw A.d(A.f("TIFFFaxDecoder7"))
g=h.w
g.toString
l=8-g
k=a-l
j=l-a
if(j>=0){if(!(l>=0&&l<9))return A.a(B.j,l)
i=B.a.a5(n&B.j[l],j)
g+=a
h.w=g
if(g===8){h.w=0
q.toString
h.x=q+1}}else{if(!(l>=0&&l<9))return A.a(B.j,l)
i=B.a.D(n&B.j[l],-j)
if(!(k>=0&&k<9))return A.a(B.r,k)
i=(i|B.a.a5(m&B.r[k],8-k))>>>0
q.toString
h.x=q+1
h.w=k}return i},
a2(a){var s,r=this,q=r.w
q.toString
s=q-a
if(s<0){q=r.x
q.toString
r.x=q-1
r.w=8+s}else r.w=s},
sd6(a){this.e=t.k.a(a)},
sd4(a){this.f=t.k.a(a)}}
A.f6.prototype={
fG(a){var s,r,q,p,o,n,m,l,k,j,i,h,g=this,f=A.j(a,null,0),e=a.k()
for(s=g.a,r=0;r<e;++r){q=a.k()
p=a.k()
o=a.j()
n=new A.f5(q,p,o,f)
if(p<13&&p>0){if(!(p<14))return A.a(B.aI,p)
m=B.aI[p]}else m=0
if(o*m>4)n.d=a.j()
else{m=a.d
n.d=m
a.d=m+4}s.h(0,q,n)
if(q===256){m=n.d
m.toString
f.d=m
g.b=n.aA()}else if(q===257){m=n.d
m.toString
f.d=m
g.c=n.aA()}else if(q===262){m=n.d
m.toString
f.d=m
g.d=n.aA()}else if(q===259){m=n.d
m.toString
f.d=m
g.e=n.aA()}else if(q===258){m=n.d
m.toString
f.d=m
g.f=n.aA()}else if(q===277){m=n.d
m.toString
f.d=m
g.r=n.aA()}else if(q===317){m=n.d
m.toString
f.d=m
g.z=n.aA()}else if(q===339){m=n.d
m.toString
f.d=m
g.w=n.aA()}else if(q===320){g.sjx(n.d8())
g.go=0
m=g.fy.length/3|0
g.id=m
g.k1=m*2}}if(g.b===0||g.c===0)return
m=g.fy
if(m!=null&&g.f===8)for(l=m.length,r=0;r<l;++r){m=g.fy
if(!(r<m.length))return A.a(m,r)
B.b.h(m,r,B.a.i(m[r],8))}if(g.d===0)g.y=!0
if(s.a3(324)){g.ax=g.bi(322)
g.ay=g.bi(323)
g.seY(g.cb(324))
g.seX(g.cb(325))}else{g.ax=g.ca(322,g.b)
if(!s.a3(278))g.ay=g.ca(323,g.c)
else{k=g.bi(278)
if(k===-1)g.ay=g.c
else g.ay=k}g.seY(g.cb(273))
g.seX(g.cb(279))}m=g.b
j=g.ax
g.cx=B.a.V(m+j-1,j)
j=g.c
m=g.ay
g.cy=B.a.V(j+m-1,m)
g.dx=g.ca(266,1)
g.dy=g.bi(292)
g.fr=g.bi(293)
g.bi(338)
switch(g.d){case 0:case 1:s=g.f
if(s===1&&g.r===1)g.x=0
else if(s===4&&g.r===1)g.x=1
else if(B.a.I(s,8)===0){s=g.r
if(s===1)g.x=2
else if(s===2)g.x=3
else g.x=8}break
case 2:if(B.a.I(g.f,8)===0){s=g.r
if(s===3)g.x=5
else if(s===4)g.x=6
else g.x=8}break
case 3:if(g.r===1){s=g.f
s=s===4||s===8||s===16}else s=!1
if(s)g.x=4
break
case 4:if(g.f===1&&g.r===1)g.x=0
break
case 6:if(g.e===7&&g.f===8&&g.r===3)g.x=5
else{if(s.a3(530)){i=s.q(0,530).d8()
s=i.length
if(0>=s)return A.a(i,0)
m=g.Q=i[0]
if(1>=s)return A.a(i,1)
s=g.as=i[1]
h=m
m=s
s=h}else{g.as=g.Q=2
s=2
m=2}if(s*m===1)g.x=8
else if(g.f===8&&g.r===3)g.x=7}break
default:if(B.a.I(g.f,8)===0)g.x=8
break}},
cl(a){var s,r,q,p,o=this
o.k2=A.T(o.b,o.c,B.f,null,null)
s=0
r=0
while(!0){q=o.cy
q===$&&A.c("tilesY")
if(!(s<q))break
p=0
while(!0){q=o.cx
q===$&&A.c("tilesX")
if(!(p<q))break
o.hz(a,p,s);++p;++r}++s}q=o.k2
q.toString
return q},
hz(c1,c2,c3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3,b4,b5,b6=this,b7=null,b8="colorMapRed",b9="colorMapGreen",c0="colorMapBlue"
if(b6.x===0){b6.hr(c1,c2,c3)
return}o=b6.cx
o===$&&A.c("tilesX")
n=c3*o+c2
o=b6.ch
if(!(n>=0&&n<o.length))return A.a(o,n)
c1.d=o[n]
o=b6.ax
m=c2*o
l=b6.ay
k=c3*l
j=b6.CW
if(!(n<j.length))return A.a(j,n)
s=j[n]
i=o*l*b6.r
o=b6.f
l=o===16
if(l)i*=2
else if(o===32)i*=4
r=null
if(o===8||l||o===32||o===64){o=b6.e
if(o===1)r=c1
else if(o===5){r=A.l(new Uint8Array(i),!1,b7,0)
q=A.lh()
try{q.eG(A.j(c1,s,0),r.a)}catch(h){p=A.a0(h)
A.jM(p)}if(b6.z===2)for(g=0;g<b6.ay;++g){f=b6.r
o=b6.ax
e=f*(g*o+1)
for(d=o*f;f<d;++f){o=r
l=o.a
o=o.d+e
if(!(o>=0&&o<l.length))return A.a(l,o)
j=l[o]
c=r
b=b6.r
a=c.a
b=c.d+(e-b)
if(!(b>=0&&b<a.length))return A.a(a,b)
J.n(l,o,j+a[b]);++e}}}else if(o===32773){r=A.l(new Uint8Array(i),!1,b7,0)
b6.dL(c1,i,r.a)}else if(o===32946){o=A.l4(c1.bQ(0,0,s)).c
r=A.l(t.L.a(A.z(o.c.buffer,0,o.a)),!1,b7,0)}else if(o===8)r=A.l(B.u.bG(A.bB(t.L.a(c1.bQ(0,0,s)),1,b7,0),!1),!1,b7,0)
else if(o===6){if(b6.k2==null)b6.k2=A.T(b6.b,b6.c,B.f,b7,b7)
a0=new A.c7().a6(c1.bQ(0,0,s))
o=b6.k2
o.toString
b6.ih(a0,o,m,k,b6.ax,b6.ay)
if(b6.k3!=null){o=b6.k2
o.toString
l=new A.e9(A.J(t.jv,t.r))
l.fz(o,16,3)
b6.k3=l}return}else throw A.d(A.f("Unsupported Compression Type: "+o))
a1=k
a2=0
while(!0){if(!(a2<b6.ay&&a1<b6.c))break
a3=m
a4=0
while(!0){if(!(a4<b6.ax&&a3<b6.b))break
o=b6.r
if(o===1){o=b6.w
if(o===3){o=b6.f
if(o===32){o=r.j()
$.A()[0]=o
o=$.bt()
if(0>=o.length)return A.a(o,0)
a5=o[0]}else if(o===64)a5=r.cp()
else if(o===16){o=r.k()
if($.O==null)A.aP()
l=$.O
if(!(o<l.length))return A.a(l,o)
a5=l[o]}else a5=0
o=b6.k3
if(o!=null)o.b1(a3,a1,a5)
if(b6.k2!=null){a6=B.c.m(B.c.p(a5*255,0,255))
if(b6.d===3&&b6.fy!=null){o=b6.fy
o.toString
l=b6.go
l===$&&A.c(b8)
l+=a6
j=o.length
if(!(l>=0&&l<j))return A.a(o,l)
l=o[l]
c=b6.id
c===$&&A.c(b9)
c+=a6
if(!(c>=0&&c<j))return A.a(o,c)
c=o[c]
b=b6.k1
b===$&&A.c(c0)
b+=a6
if(!(b>=0&&b<j))return A.a(o,b)
b=o[b]
a7=(B.c.m(B.a.p(255,0,255))<<24|B.c.m(B.a.p(b,0,255))<<16|B.c.m(B.a.p(c,0,255))<<8|B.c.m(B.a.p(l,0,255)))>>>0}else a7=(B.c.m(B.a.p(255,0,255))<<24|B.c.m(B.a.p(a6,0,255))<<16|B.c.m(B.a.p(a6,0,255))<<8|B.c.m(B.a.p(a6,0,255)))>>>0
o=b6.k2
l=o.x
o=a1*o.a+a3
if(!(o>=0&&o<l.length))return A.a(l,o)
l[o]=a7}}else{l=b6.f
if(l===8)if(o===2){o=r
l=o.a
o=o.d++
if(!(o>=0&&o<l.length))return A.a(l,o)
o=l[o]
$.a1()[0]=o
o=$.a7()
if(0>=o.length)return A.a(o,0)
a6=o[0]}else{o=r
l=o.a
o=o.d++
if(!(o>=0&&o<l.length))return A.a(l,o)
a6=l[o]}else if(l===16)if(o===2){o=r.k()
$.a6()[0]=o
o=$.ag()
if(0>=o.length)return A.a(o,0)
a6=o[0]}else a6=r.k()
else if(l===32)if(o===2){o=r.j()
$.A()[0]=o
o=$.P()
if(0>=o.length)return A.a(o,0)
a6=o[0]}else a6=r.j()
else a6=0
o=b6.k3
if(o!=null)o.b1(a3,a1,a6)
if(b6.k2!=null){o=b6.f
if(o===16)a6=B.a.i(a6,8)
else if(o===32)a6=B.a.i(a6,24)
o=b6.d
if(o===0)a6=255-a6
if(o===3&&b6.fy!=null){o=b6.fy
o.toString
l=b6.go
l===$&&A.c(b8)
l+=a6
j=o.length
if(!(l>=0&&l<j))return A.a(o,l)
l=o[l]
c=b6.id
c===$&&A.c(b9)
c+=a6
if(!(c>=0&&c<j))return A.a(o,c)
c=o[c]
b=b6.k1
b===$&&A.c(c0)
b+=a6
if(!(b>=0&&b<j))return A.a(o,b)
b=o[b]
a7=(B.c.m(B.a.p(255,0,255))<<24|B.c.m(B.a.p(b,0,255))<<16|B.c.m(B.a.p(c,0,255))<<8|B.c.m(B.a.p(l,0,255)))>>>0}else a7=(B.c.m(B.a.p(255,0,255))<<24|B.c.m(B.a.p(a6,0,255))<<16|B.c.m(B.a.p(a6,0,255))<<8|B.c.m(B.a.p(a6,0,255)))>>>0
o=b6.k2
l=o.x
o=a1*o.a+a3
if(!(o>=0&&o<l.length))return A.a(l,o)
l[o]=a7}}}else if(o===2){o=b6.f
if(o===8){o=b6.w===2
if(o){l=r
j=l.a
l=l.d++
if(!(l>=0&&l<j.length))return A.a(j,l)
l=j[l]
$.a1()[0]=l
l=$.a7()
if(0>=l.length)return A.a(l,0)
a6=l[0]}else{l=r
j=l.a
l=l.d++
if(!(l>=0&&l<j.length))return A.a(j,l)
a6=j[l]}if(o){o=r
l=o.a
o=o.d++
if(!(o>=0&&o<l.length))return A.a(l,o)
o=l[o]
$.a1()[0]=o
o=$.a7()
if(0>=o.length)return A.a(o,0)
a8=o[0]}else{o=r
l=o.a
o=o.d++
if(!(o>=0&&o<l.length))return A.a(l,o)
a8=l[o]}}else if(o===16){if(b6.w===2){o=r.k()
$.a6()[0]=o
o=$.ag()
if(0>=o.length)return A.a(o,0)
a6=o[0]}else a6=r.k()
if(b6.w===2){o=r.k()
$.a6()[0]=o
o=$.ag()
if(0>=o.length)return A.a(o,0)
a8=o[0]}else a8=r.k()}else if(o===32){if(b6.w===2){o=r.j()
$.A()[0]=o
o=$.P()
if(0>=o.length)return A.a(o,0)
a6=o[0]}else a6=r.j()
if(b6.w===2){o=r.j()
$.A()[0]=o
o=$.P()
if(0>=o.length)return A.a(o,0)
a8=o[0]}else a8=r.j()}else{a6=0
a8=0}o=b6.k3
if(o!=null){o.b1(a3,a1,a6)
b6.k3.bt(a3,a1,a8)}if(b6.k2!=null){o=b6.f
l=o===16
if(l)a6=B.a.i(a6,8)
else if(o===32)a6=B.a.i(a6,24)
if(l)a8=B.a.i(a8,8)
else if(o===32)a8=B.a.i(a8,24)
o=B.c.m(B.a.p(a8,0,255))
l=B.c.m(B.a.p(a6,0,255))
j=B.c.m(B.a.p(a6,0,255))
c=B.c.m(B.a.p(a6,0,255))
b=b6.k2
a=b.x
b=a1*b.a+a3
if(!(b>=0&&b<a.length))return A.a(a,b)
a[b]=(o<<24|l<<16|j<<8|c)>>>0}}else if(o===3){o=b6.w
if(o===3){o=b6.f
if(o===32){o=r.j()
l=$.A()
l[0]=o
o=$.bt()
if(0>=o.length)return A.a(o,0)
a9=o[0]
l[0]=r.j()
b0=o[0]
l[0]=r.j()
b1=o[0]}else if(o===64){a9=r.cp()
b0=0
b1=0}else if(o===16){o=r.k()
if($.O==null)A.aP()
l=$.O
if(!(o<l.length))return A.a(l,o)
a9=l[o]
o=r.k()
if($.O==null)A.aP()
l=$.O
if(!(o<l.length))return A.a(l,o)
b0=l[o]
o=r.k()
if($.O==null)A.aP()
l=$.O
if(!(o<l.length))return A.a(l,o)
b1=l[o]}else{a9=0
b0=0
b1=0}o=b6.k3
if(o!=null){o.b1(a3,a1,a9)
b6.k3.bt(a3,a1,b0)
b6.k3.bW(a3,a1,b1)}if(b6.k2!=null){b2=B.c.m(B.c.p(a9*255,0,255))
b3=B.c.m(B.c.p(b0*255,0,255))
b4=B.c.m(B.c.p(b1*255,0,255))
o=B.c.m(B.a.p(255,0,255))
l=B.c.m(B.a.p(b4,0,255))
j=B.c.m(B.a.p(b3,0,255))
c=B.c.m(B.a.p(b2,0,255))
b=b6.k2
a=b.x
b=a1*b.a+a3
if(!(b>=0&&b<a.length))return A.a(a,b)
a[b]=(o<<24|l<<16|j<<8|c)>>>0}}else{l=b6.f
if(l===8){o=o===2
if(o){l=r
j=l.a
l=l.d++
if(!(l>=0&&l<j.length))return A.a(j,l)
l=j[l]
$.a1()[0]=l
l=$.a7()
if(0>=l.length)return A.a(l,0)
a9=l[0]}else{l=r
j=l.a
l=l.d++
if(!(l>=0&&l<j.length))return A.a(j,l)
a9=j[l]}if(o){l=r
j=l.a
l=l.d++
if(!(l>=0&&l<j.length))return A.a(j,l)
l=j[l]
$.a1()[0]=l
l=$.a7()
if(0>=l.length)return A.a(l,0)
b0=l[0]}else{l=r
j=l.a
l=l.d++
if(!(l>=0&&l<j.length))return A.a(j,l)
b0=j[l]}if(o){o=r
l=o.a
o=o.d++
if(!(o>=0&&o<l.length))return A.a(l,o)
o=l[o]
$.a1()[0]=o
o=$.a7()
if(0>=o.length)return A.a(o,0)
b1=o[0]}else{o=r
l=o.a
o=o.d++
if(!(o>=0&&o<l.length))return A.a(l,o)
b1=l[o]}}else if(l===16){if(o===2){o=r.k()
$.a6()[0]=o
o=$.ag()
if(0>=o.length)return A.a(o,0)
a9=o[0]}else a9=r.k()
if(b6.w===2){o=r.k()
$.a6()[0]=o
o=$.ag()
if(0>=o.length)return A.a(o,0)
b0=o[0]}else b0=r.k()
if(b6.w===2){o=r.k()
$.a6()[0]=o
o=$.ag()
if(0>=o.length)return A.a(o,0)
b1=o[0]}else b1=r.k()}else if(l===32){if(o===2){o=r.j()
$.A()[0]=o
o=$.P()
if(0>=o.length)return A.a(o,0)
a9=o[0]}else a9=r.j()
if(b6.w===2){o=r.j()
$.A()[0]=o
o=$.P()
if(0>=o.length)return A.a(o,0)
b0=o[0]}else b0=r.j()
if(b6.w===2){o=r.j()
$.A()[0]=o
o=$.P()
if(0>=o.length)return A.a(o,0)
b1=o[0]}else b1=r.j()}else{a9=0
b0=0
b1=0}o=b6.k3
if(o!=null){o.b1(a3,a1,a9)
b6.k3.bt(a3,a1,b0)
b6.k3.bW(a3,a1,b1)}if(b6.k2!=null){o=b6.f
l=o===16
if(l)a9=B.a.i(a9,8)
else if(o===32)a9=B.a.i(a9,24)
if(l)b0=B.a.i(b0,8)
else if(o===32)b0=B.a.i(b0,24)
if(l)b1=B.a.i(b1,8)
else if(o===32)b1=B.a.i(b1,24)
o=B.c.m(B.a.p(255,0,255))
l=B.c.m(B.a.p(b1,0,255))
j=B.c.m(B.a.p(b0,0,255))
c=B.c.m(B.a.p(a9,0,255))
b=b6.k2
a=b.x
b=a1*b.a+a3
if(!(b>=0&&b<a.length))return A.a(a,b)
a[b]=(o<<24|l<<16|j<<8|c)>>>0}}}else if(o>=4){o=b6.w
if(o===3){o=b6.f
if(o===32){o=r.j()
l=$.A()
l[0]=o
o=$.bt()
if(0>=o.length)return A.a(o,0)
a9=o[0]
l[0]=r.j()
b0=o[0]
l[0]=r.j()
b1=o[0]
l[0]=r.j()
b5=o[0]}else if(o===64){a9=r.cp()
b0=0
b1=0
b5=0}else if(o===16){o=r.k()
if($.O==null)A.aP()
l=$.O
if(!(o<l.length))return A.a(l,o)
a9=l[o]
o=r.k()
if($.O==null)A.aP()
l=$.O
if(!(o<l.length))return A.a(l,o)
b0=l[o]
o=r.k()
if($.O==null)A.aP()
l=$.O
if(!(o<l.length))return A.a(l,o)
b1=l[o]
o=r.k()
if($.O==null)A.aP()
l=$.O
if(!(o<l.length))return A.a(l,o)
b5=l[o]}else{a9=0
b0=0
b1=0
b5=0}o=b6.k3
if(o!=null){o.b1(a3,a1,a9)
b6.k3.bt(a3,a1,b0)
b6.k3.bW(a3,a1,b1)
b6.k3.de(a3,a1,b5)}if(b6.k2!=null){b2=B.c.m(B.c.p(a9*255,0,255))
b3=B.c.m(B.c.p(b0*255,0,255))
b4=B.c.m(B.c.p(b1*255,0,255))
o=B.c.m(B.a.p(B.c.m(B.c.p(b5*255,0,255)),0,255))
l=B.c.m(B.a.p(b4,0,255))
j=B.c.m(B.a.p(b3,0,255))
c=B.c.m(B.a.p(b2,0,255))
b=b6.k2
a=b.x
b=a1*b.a+a3
if(!(b>=0&&b<a.length))return A.a(a,b)
a[b]=(o<<24|l<<16|j<<8|c)>>>0}}else{l=b6.f
if(l===8){o=o===2
if(o){l=r
j=l.a
l=l.d++
if(!(l>=0&&l<j.length))return A.a(j,l)
l=j[l]
$.a1()[0]=l
l=$.a7()
if(0>=l.length)return A.a(l,0)
a9=l[0]}else{l=r
j=l.a
l=l.d++
if(!(l>=0&&l<j.length))return A.a(j,l)
a9=j[l]}if(o){l=r
j=l.a
l=l.d++
if(!(l>=0&&l<j.length))return A.a(j,l)
l=j[l]
$.a1()[0]=l
l=$.a7()
if(0>=l.length)return A.a(l,0)
b0=l[0]}else{l=r
j=l.a
l=l.d++
if(!(l>=0&&l<j.length))return A.a(j,l)
b0=j[l]}if(o){l=r
j=l.a
l=l.d++
if(!(l>=0&&l<j.length))return A.a(j,l)
l=j[l]
$.a1()[0]=l
l=$.a7()
if(0>=l.length)return A.a(l,0)
b1=l[0]}else{l=r
j=l.a
l=l.d++
if(!(l>=0&&l<j.length))return A.a(j,l)
b1=j[l]}if(o){o=r
l=o.a
o=o.d++
if(!(o>=0&&o<l.length))return A.a(l,o)
o=l[o]
$.a1()[0]=o
o=$.a7()
if(0>=o.length)return A.a(o,0)
b5=o[0]}else{o=r
l=o.a
o=o.d++
if(!(o>=0&&o<l.length))return A.a(l,o)
b5=l[o]}}else if(l===16){if(o===2){o=r.k()
$.a6()[0]=o
o=$.ag()
if(0>=o.length)return A.a(o,0)
a9=o[0]}else a9=r.k()
if(b6.w===2){o=r.k()
$.a6()[0]=o
o=$.ag()
if(0>=o.length)return A.a(o,0)
b0=o[0]}else b0=r.k()
if(b6.w===2){o=r.k()
$.a6()[0]=o
o=$.ag()
if(0>=o.length)return A.a(o,0)
b1=o[0]}else b1=r.k()
if(b6.w===2){o=r.k()
$.a6()[0]=o
o=$.ag()
if(0>=o.length)return A.a(o,0)
b5=o[0]}else b5=r.k()}else if(l===32){if(o===2){o=r.j()
$.A()[0]=o
o=$.P()
if(0>=o.length)return A.a(o,0)
a9=o[0]}else a9=r.j()
if(b6.w===2){o=r.j()
$.A()[0]=o
o=$.P()
if(0>=o.length)return A.a(o,0)
b0=o[0]}else b0=r.j()
if(b6.w===2){o=r.j()
$.A()[0]=o
o=$.P()
if(0>=o.length)return A.a(o,0)
b1=o[0]}else b1=r.j()
if(b6.w===2){o=r.j()
$.A()[0]=o
o=$.P()
if(0>=o.length)return A.a(o,0)
b5=o[0]}else b5=r.j()}else{a9=0
b0=0
b1=0
b5=0}o=b6.k3
if(o!=null){o.b1(a3,a1,a9)
b6.k3.bt(a3,a1,b0)
b6.k3.bW(a3,a1,b1)
b6.k3.de(a3,a1,b5)}if(b6.k2!=null){o=b6.f
l=o===16
if(l)a9=B.a.i(a9,8)
else if(o===32)a9=B.a.i(a9,24)
if(l)b0=B.a.i(b0,8)
else if(o===32)b0=B.a.i(b0,24)
if(l)b1=B.a.i(b1,8)
else if(o===32)b1=B.a.i(b1,24)
if(l)b5=B.a.i(b5,8)
else if(o===32)b5=B.a.i(b5,24)
o=B.c.m(B.a.p(b5,0,255))
l=B.c.m(B.a.p(b1,0,255))
j=B.c.m(B.a.p(b0,0,255))
c=B.c.m(B.a.p(a9,0,255))
b=b6.k2
a=b.x
b=a1*b.a+a3
if(!(b>=0&&b<a.length))return A.a(a,b)
a[b]=(o<<24|l<<16|j<<8|c)>>>0}}}++a4;++a3}++a2;++a1}}else throw A.d(A.f("Unsupported bitsPerSample: "+o))},
ih(a,b,c,d,e,f){var s,r,q,p,o,n,m,l,k,j,i,h
for(s=a.x,r=a.a,q=s.length,p=b.x,o=b.a,n=p.length,m=0;m<f;++m)for(l=m*r,k=(m+d)*o,j=0;j<e;++j){i=l+j
if(!(i>=0&&i<q))return A.a(s,i)
i=s[i]
h=k+(j+c)
if(!(h>=0&&h<n))return A.a(p,h)
p[h]=i}},
hr(b0,b1,b2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5=this,a6=null,a7=4278190080,a8=4294967295,a9=a5.cx
a9===$&&A.c("tilesX")
r=b2*a9+b1
a9=a5.ch
if(!(r>=0&&r<a9.length))return A.a(a9,r)
b0.d=a9[r]
a9=a5.ax
q=b1*a9
p=a5.ay
o=b2*p
n=a5.CW
if(!(r<n.length))return A.a(n,r)
m=n[r]
s=null
n=a5.e
if(n===32773){l=B.a.I(a9,8)===0?B.a.F(a9,8)*p:(B.a.F(a9,8)+1)*p
s=A.l(new Uint8Array(a9*p),!1,a6,0)
a5.dL(b0,l,s.a)}else if(n===5){s=A.l(new Uint8Array(a9*p),!1,a6,0)
A.lh().eG(A.j(b0,m,0),s.a)
if(a5.z===2)for(k=0;k<a5.c;++k){j=a5.r
i=j*(k*a5.b+1)
for(;a9=a5.b,p=a5.r,j<a9*p;++j){a9=s
n=a9.a
a9=a9.d+i
if(!(a9>=0&&a9<n.length))return A.a(n,a9)
h=n[a9]
g=s
f=g.a
p=g.d+(i-p)
if(!(p>=0&&p<f.length))return A.a(f,p)
J.n(n,a9,h+f[p]);++i}}}else if(n===2){s=A.l(new Uint8Array(a9*p),!1,a6,0)
try{A.ke(a5.dx,a9,p).jH(s,b0,0,a5.ay)}catch(e){}}else if(n===3){s=A.l(new Uint8Array(a9*p),!1,a6,0)
try{A.ke(a5.dx,a9,p).jI(s,b0,0,a5.ay,a5.dy)}catch(e){}}else if(n===4){s=A.l(new Uint8Array(a9*p),!1,a6,0)
try{A.ke(a5.dx,a9,p).jM(s,b0,0,a5.ay,a5.fr)}catch(e){}}else if(n===8)s=A.l(B.u.bG(A.bB(t.L.a(b0.bQ(0,0,m)),1,a6,0),!1),!1,a6,0)
else if(n===32946){a9=A.l4(b0.bQ(0,0,m)).c
s=A.l(t.L.a(A.z(a9.c.buffer,0,a9.a)),!1,a6,0)}else if(n===1)s=b0
else throw A.d(A.f("Unsupported Compression Type: "+n))
d=new A.i2(s)
a9=a5.y
c=a9?a7:a8
b=a9?a8:a7
a=a5.k2
for(a9=a.x,p=a.a,n=a9.length,h=a.b,a0=o,a1=0;a1<a5.ay;++a1,++a0){for(g=a0*p,f=a0<h,a2=q,a3=0;a3<a5.ax;++a3,++a2){if(!f||a2>=p)break
a4=g+a2
if(d.N(1)===0){if(!(a4>=0&&a4<n))return A.a(a9,a4)
a9[a4]=b}else{if(!(a4>=0&&a4<n))return A.a(a9,a4)
a9[a4]=c}}d.c=0}},
dL(a,b,c){var s,r,q,p,o,n,m,l,k,j,i
t.L.a(c)
for(s=J.R(c),r=0,q=0;q<b;){p=r+1
o=a.a
n=a.d
m=n+r
l=o.length
if(!(m>=0&&m<l))return A.a(o,m)
m=o[m]
$.a1()[0]=m
m=$.a7()
if(0>=m.length)return A.a(m,0)
k=m[0]
if(k>=0&&k<=127)for(o=k+1,r=p,j=0;j<o;++j,q=i,r=p){i=q+1
p=r+1
n=a.a
m=a.d+r
if(!(m>=0&&m<n.length))return A.a(n,m)
s.h(c,q,n[m])}else{m=k<=-1&&k>=-127
r=p+1
if(m){n+=p
if(!(n>=0&&n<l))return A.a(o,n)
n=o[n]
for(o=-k+1,j=0;j<o;++j,q=i){i=q+1
s.h(c,q,n)}}}}},
ca(a,b){var s=this.a
if(!s.a3(a))return b
return s.q(0,a).kq()},
bi(a){return this.ca(a,0)},
cb(a){var s=this.a
if(!s.a3(a))return null
return s.q(0,a).d8()},
seY(a){this.ch=t.T.a(a)},
seX(a){this.CW=t.T.a(a)},
sjx(a){this.fy=t.T.a(a)}}
A.i4.prototype={}
A.hB.prototype={
eG(a,b){var s,r,q,p,o,n,m,l,k=this,j="_out",i="_bufferLength"
t.L.a(b)
k.sfR(b)
s=b.length
k.w=0
r=t.D.a(a.a)
k.e=r
q=k.f=r.length
k.b=a.d
if(0>=q)return A.a(r,0)
if(r[0]===0){if(1>=q)return A.a(r,1)
r=r[1]===1}else r=!1
if(r)throw A.d(A.f("Invalid LZW Data"))
k.e_()
k.d=k.c=0
p=k.cM()
r=k.x
o=0
while(!0){if(!(p!==257&&k.w<s))break
if(p===256){k.e_()
p=k.cM()
k.as=0
if(p===257)break
q=k.r
q===$&&A.c(j)
J.n(q,k.w++,p)
o=p}else{q=k.Q
q.toString
if(p<q){k.dV(p)
q=k.as
q===$&&A.c(i)
n=q-1
for(;n>=0;--n){q=k.r
q===$&&A.c(j)
m=k.w++
if(!(n<4096))return A.a(r,n)
J.n(q,m,r[n])}q=k.as-1
if(!(q>=0&&q<4096))return A.a(r,q)
k.ds(o,r[q])}else{k.dV(o)
q=k.as
q===$&&A.c(i)
n=q-1
for(;n>=0;--n){q=k.r
q===$&&A.c(j)
m=k.w++
if(!(n<4096))return A.a(r,n)
J.n(q,m,r[n])}q=k.r
q===$&&A.c(j)
m=k.w++
l=k.as-1
if(!(l>=0&&l<4096))return A.a(r,l)
J.n(q,m,r[l])
l=k.as-1
if(!(l>=0&&l<4096))return A.a(r,l)
k.ds(o,r[l])}o=p}p=k.cM()}},
ds(a,b){var s,r=this,q=r.y
q===$&&A.c("_table")
s=r.Q
s.toString
if(!(s<4096))return A.a(q,s)
q[s]=b
q=r.z
q===$&&A.c("_prefix")
q[s]=a
s=r.Q=s+1
if(s===511)r.a=10
else if(s===1023)r.a=11
else if(s===2047)r.a=12},
dV(a){var s,r,q,p,o,n,m,l=this
l.as=0
s=l.x
l.as=1
r=l.y
r===$&&A.c("_table")
if(!(a<4096))return A.a(r,a)
s[0]=r[a]
q=l.z
q===$&&A.c("_prefix")
p=q[a]
for(o=1;p!==4098;o=n){n=o+1
l.as=n
if(!(p>=0&&p<4096))return A.a(r,p)
m=r[p]
if(!(o<4096))return A.a(s,o)
s[o]=m
p=q[p]}},
cM(){var s,r,q,p,o=this,n=o.b,m=o.f
m===$&&A.c("_dataLength")
if(n>=m)return 257
for(;s=o.d,r=o.a,s<r;n=p){if(n>=m)return 257
r=o.c
q=o.e
q===$&&A.c("_data")
p=n+1
o.b=p
if(!(n>=0&&n<q.length))return A.a(q,n)
o.c=(r<<8>>>0)+q[n]>>>0
o.d=s+8}n=s-r
o.d=n
n=B.a.a5(o.c,n)
r-=9
if(!(r>=0&&r<4))return A.a(B.ac,r)
return n&B.ac[r]},
e_(){var s,r,q=this
q.y=new Uint8Array(4096)
s=new Uint32Array(4096)
q.z=s
B.n.ak(s,0,4096,4098)
for(s=q.y,r=0;r<256;++r)s[r]=r
q.a=9
q.Q=258},
sfR(a){this.r=t.L.a(a)}}
A.d9.prototype={
a6(a){var s=this,r=A.l(t.L.a(a),!1,null,0)
s.b=r
r=s.a=s.ee(r)
if(r==null)return null
r=r.r
if(0>=r.length)return A.a(r,0)
return r[0].cl(s.b)},
ee(a){var s,r,q,p,o,n,m,l,k,j=null,i=A.b([],t.fZ),h=new A.i4(i),g=a.k()
if(g!==18761&&g!==19789)return j
if(g===19789)a.e=!0
else a.e=!1
q=a.k()
h.e=q
if(q!==42)return j
p=a.j()
s=A.j(a,j,0)
s.d=p
for(q=t.p,o=t.e8;p!==0;){r=null
try{n=new A.f6(A.J(q,o))
n.fG(s)
r=n
m=r
if(!(m.b!==0&&m.c!==0))break}catch(l){break}B.b.A(i,r)
m=i.length
if(m===1){if(0>=m)return A.a(i,0)
k=i[0]
h.a=k.b
if(0>=m)return A.a(i,0)
h.b=k.c}p=s.j()
if(p!==0)s.d=p}return i.length!==0?h:j}}
A.ic.prototype={
bH(){var s,r=this.a,q=r.an()
if((q&1)!==0)return!1
if((q>>>1&7)>3)return!1
if((q>>>4&1)===0)return!1
this.f.d=q>>>5
if(r.an()!==2752925)return!1
s=this.b
s.a=r.k()
s.b=r.k()
return!0},
aK(){var s,r=this,q=null
if(!r.i0())return q
s=r.b
r.d=A.T(s.a,s.b,B.f,q,q)
r.i7()
if(!r.iv())return q
return r.d},
i0(){var s,r,q,p,o=this
if(!o.bH())return!1
o.fr=A.oH()
for(s=o.dy,r=0;r<4;++r){q=new Int32Array(2)
p=new Int32Array(2)
B.b.h(s,r,new A.fg(q,p,new Int32Array(2)))}s=o.b
q=s.a
if(typeof q!=="number")return q.a8()
B.a.i(q,8)
s=s.b
if(typeof s!=="number")return s.a8()
B.a.i(s,8)
o.y=o.Q=0
o.z=q
o.as=s
o.at=B.a.i(q+15,4)
o.ax=B.a.i(s+15,4)
o.k1=0
s=o.a
q=o.f
p=q.d
p===$&&A.c("partitionLength")
p=A.lK(s.R(p))
o.c=p
s.d+=q.d
p.E(1)
o.c.E(1)
o.iB(o.x,o.fr)
o.iu()
if(!o.ix(s))return!1
o.iz()
o.c.E(1)
o.iy()
return!0},
iB(a,b){var s,r,q,p=this,o=p.c
o===$&&A.c("br")
o=o.E(1)!==0
a.a=o
if(o){a.b=p.c.E(1)!==0
if(p.c.E(1)!==0){a.c=p.c.E(1)!==0
for(o=a.d,s=0;s<4;++s){if(p.c.E(1)!==0){r=p.c
q=r.E(7)
r=r.E(1)===1?-q:q}else r=0
o[s]=r}for(o=a.e,s=0;s<4;++s){if(p.c.E(1)!==0){r=p.c
q=r.E(6)
r=r.E(1)===1?-q:q}else r=0
o[s]=r}}if(a.b)for(s=0;s<3;++s){o=b.a
o[s]=p.c.E(1)!==0?p.c.E(8):255}}else a.b=!1
return!0},
iu(){var s,r,q,p=this,o=p.w,n=p.c
n===$&&A.c("br")
o.a=n.E(1)!==0
o.b=p.c.E(6)
o.c=p.c.E(3)
n=p.c.E(1)!==0
o.d=n
if(n)if(p.c.E(1)!==0){for(n=o.e,s=0;s<4;++s)if(p.c.E(1)!==0){r=p.c
q=r.E(6)
n[s]=r.E(1)===1?-q:q}for(n=o.f,s=0;s<4;++s)if(p.c.E(1)!==0){r=p.c
q=r.E(6)
n[s]=r.E(1)===1?-q:q}}if(o.b===0)n=0
else n=o.a?1:2
p.au=n
return!0},
ix(a){var s,r,q,p,o,n,m,l,k,j,i,h=a.c-a.d,g=this.c
g===$&&A.c("br")
g=B.a.B(1,g.E(2))
this.cy=g
s=g-1
r=s*3
if(h<r)return!1
for(g=this.db,q=0,p=0;p<s;++p,r=i){o=a.bd(3,q)
n=o.a
m=o.d
l=n.length
if(!(m>=0&&m<l))return A.a(n,m)
k=n[m]
j=m+1
if(!(j<l))return A.a(n,j)
j=n[j]
m+=2
if(!(m<l))return A.a(n,m)
i=r+((k|j<<8|n[m]<<16)>>>0)
if(i>h)i=h
n=new A.dc(a.b2(i-r,r))
n.b=254
n.c=0
n.d=-8
B.b.h(g,p,n)
q+=3}B.b.h(g,s,A.lK(a.b2(h-r,a.d-a.b+r)))
return r<h},
iz(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=this,e=f.c
e===$&&A.c("br")
s=e.E(7)
r=f.c.E(1)!==0?f.c.bs(4):0
q=f.c.E(1)!==0?f.c.bs(4):0
p=f.c.E(1)!==0?f.c.bs(4):0
o=f.c.E(1)!==0?f.c.bs(4):0
n=f.c.E(1)!==0?f.c.bs(4):0
m=f.x
for(e=f.dy,l=m.d,k=0;k<4;++k){if(m.a){j=l[k]
if(!m.c)j+=s}else{if(k>0){i=e[0]
if(!(k>=0&&k<4))return A.a(e,k)
e[k]=i
continue}j=s}h=e[k]
i=h.a
g=j+r
if(g<0)g=0
else if(g>127)g=127
i[0]=B.T[g]
if(j<0)g=0
else g=j>127?127:j
i[1]=B.U[g]
g=h.b
i=j+q
if(i<0)i=0
else if(i>127)i=127
g[0]=B.T[i]*2
i=j+p
if(i<0)i=0
else if(i>127)i=127
g[1]=B.U[i]*101581>>>16
if(g[1]<8)g[1]=8
i=h.c
g=j+o
if(g<0)g=0
else if(g>117)g=117
i[0]=B.T[g]
g=j+n
if(g<0)g=0
else if(g>127)g=127
i[1]=B.U[g]}},
iy(){var s,r,q,p,o,n,m=this,l=m.fr
for(s=0;s<4;++s)for(r=0;r<8;++r)for(q=0;q<3;++q)for(p=0;p<11;++p){o=m.c
o===$&&A.c("br")
n=o.J(B.cf[s][r][q][p])!==0?m.c.E(8):B.cw[s][r][q][p]
o=l.b
if(!(s<o.length))return A.a(o,s)
o=o[s]
if(!(r<o.length))return A.a(o,r)
o=o[r].a
if(!(q<o.length))return A.a(o,q)
o[q][p]=n}o=m.c
o===$&&A.c("br")
o=o.E(1)!==0
m.fx=o
if(o)m.fy=m.c.E(8)},
iE(){var s,r,q,p,o,n,m,l,k,j,i,h,g=this,f=g.au
f.toString
if(f>0){s=g.w
for(f=s.e,r=s.f,q=g.x,p=q.e,o=0;o<4;++o){if(q.a){n=p[o]
if(!q.c){m=s.b
m.toString
n+=m}}else n=s.b
for(l=0;l<=1;++l){m=g.ab
m===$&&A.c("_fStrengths")
if(!(o<m.length))return A.a(m,o)
k=m[o][l]
m=s.d
m===$&&A.c("useLfDelta")
if(m){n.toString
j=n+f[0]
if(l!==0)j+=r[0]}else j=n
j.toString
if(j<0)j=0
else if(j>63)j=63
if(j>0){m=s.c
m===$&&A.c("sharpness")
if(m>0){i=m>4?B.a.i(j,2):B.a.i(j,1)
h=9-m
if(i>h)i=h}else i=j
if(i<1)i=1
k.b=i
k.a=2*j+i
if(j>=40)m=2
else m=j>=15?1:0
k.d=m}else k.a=0
k.c=l!==0}}}},
i7(){var s,r,q,p,o,n,m,l,k,j,i,h=this,g=null,f=h.b,e=f.at
if(e!=null)h.aZ=e
s=J.ah(4,t.jz)
for(e=t.hP,r=0;r<4;++r)s[r]=A.b([new A.aW(),new A.aW()],e)
h.sfZ(t.mL.a(s))
e=h.at
e.toString
s=J.ah(e,t.ij)
for(q=0;q<e;++q){p=new Uint8Array(16)
o=new Uint8Array(8)
s[q]=new A.dg(p,o,new Uint8Array(8))}h.sh1(t.f4.a(s))
h.ok=new Uint8Array(832)
e=h.at
e.toString
h.go=new Uint8Array(4*e)
p=h.p4=16*e
o=h.R8=8*e
n=h.au
n.toString
if(!(n<3))return A.a(B.y,n)
m=B.y[n]
l=m*p
k=(m/2|0)*o
h.p1=A.l(new Uint8Array(16*p+l),!1,g,l)
p=8*o+k
h.p2=A.l(new Uint8Array(p),!1,g,k)
h.p3=A.l(new Uint8Array(p),!1,g,k)
f=f.a
h.RG=A.l(new Uint8Array(f),!1,g,0)
j=B.a.i(f+1,1)
h.rx=A.l(new Uint8Array(j),!1,g,0)
h.ry=A.l(new Uint8Array(j),!1,g,0)
if(n===2)h.ch=h.ay=0
else{f=h.y
f===$&&A.c("_cropLeft")
f=B.a.F(f-m,16)
h.ay=f
p=h.Q
p.toString
p=B.a.F(p-m,16)
h.ch=p
if(f<0)h.ay=0
if(p<0)h.ch=0}f=h.as
f.toString
f=B.a.F(f+15+m,16)
h.cx=f
p=h.z
p===$&&A.c("_cropRight")
p=B.a.F(p+15+m,16)
h.CW=p
if(p>e)h.CW=e
p=h.ax
p.toString
if(f>p)h.cx=p
i=e+1
s=J.ah(i,t.f_)
for(q=0;q<i;++q)s[q]=new A.de()
h.sh0(t.jt.a(s))
f=h.at
f.toString
s=J.ah(f,t.h2)
for(q=0;q<f;++q){e=new Int16Array(384)
s[q]=new A.df(e,new Uint8Array(16))}h.sh_(t.as.a(s))
f=h.at
f.toString
h.sfY(t.kb.a(A.H(f,g,!1,t.fA)))
h.iE()
A.os()
h.e=new A.id()
return!0},
iv(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=this,d="isIntra4x4"
e.y2=0
s=e.id
r=e.x
q=e.db
p=0
while(!0){o=e.cx
o.toString
if(!(p<o))break
o=e.cy
o===$&&A.c("_numPartitions")
o=(p&o-1)>>>0
if(!(o>=0&&o<8))return A.a(q,o)
n=q[o]
while(!0){p=e.y1
o=e.at
o.toString
if(!(p<o))break
o=e.k3
o===$&&A.c("_mbInfo")
m=o.length
if(0>=m)return A.a(o,0)
l=o[0]
k=1+p
if(!(k<m))return A.a(o,k)
j=o[k]
k=e.ai
k===$&&A.c("_mbData")
if(!(p<k.length))return A.a(k,p)
i=k[p]
if(r.b){p=e.c
p===$&&A.c("br")
p=p.J(e.fr.a[0])
o=e.c
m=e.fr
e.k1=p===0?o.J(m.a[1]):2+o.J(m.a[2])}p=e.fx
p===$&&A.c("_useSkipProba")
if(p){p=e.c
p===$&&A.c("br")
o=e.fy
o===$&&A.c("_skipP")
h=p.J(o)!==0}else h=!1
e.iw()
if(!h)h=e.iA(j,n)
else{l.a=j.a=0
p=i.b
p===$&&A.c(d)
if(!p)l.b=j.b=0
i.f=i.e=0}p=e.au
p.toString
if(p>0){p=e.k4
p===$&&A.c("_fInfo")
o=e.y1
m=e.ab
m===$&&A.c("_fStrengths")
k=e.k1
k===$&&A.c("_segment")
if(!(k<m.length))return A.a(m,k)
k=m[k]
m=i.b
m===$&&A.c(d)
B.b.h(p,o,k[m?1:0])
p=e.k4
o=e.y1
if(!(o<p.length))return A.a(p,o)
g=p[o]
g.c=g.c||!h}++e.y1}p=e.k3
p===$&&A.c("_mbInfo")
if(0>=p.length)return A.a(p,0)
l=p[0]
l.b=l.a=0
B.e.ak(s,0,4,0)
e.y1=0
e.j8()
p=e.au
p.toString
if(p>0){p=e.y2
o=e.ch
o===$&&A.c("_tlMbY")
if(p>=o){o=e.cx
o.toString
o=p<=o
f=o}else f=!1}else f=!1
if(!e.hV(f))return!1
p=++e.y2}return!0},
j8(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3=this,a4=null,a5="_dsp",a6=a3.y2,a7=a3.ok
a7===$&&A.c("_yuvBlock")
s=A.l(a7,!1,a4,40)
r=A.l(a7,!1,a4,584)
q=A.l(a7,!1,a4,600)
a7=a6>0
p=0
while(!0){o=a3.at
o.toString
if(!(p<o))break
o=a3.ai
o===$&&A.c("_mbData")
if(!(p<o.length))return A.a(o,p)
n=o[p]
if(p>0){for(m=-1;m<16;++m){o=m*32
s.am(o-4,4,s,o+12)}for(m=-1;m<8;++m){o=m*32
l=o-4
o+=4
r.am(l,4,r,o)
q.am(l,4,q,o)}}else{for(m=0;m<16;++m)J.n(s.a,s.d+(m*32-1),129)
for(m=0;m<8;++m){o=m*32-1
J.n(r.a,r.d+o,129)
J.n(q.a,q.d+o,129)}if(a7){J.n(q.a,q.d+-33,129)
J.n(r.a,r.d+-33,129)
J.n(s.a,s.d+-33,129)}}o=a3.k2
o===$&&A.c("_yuvT")
if(!(p<o.length))return A.a(o,p)
k=o[p]
j=n.a
i=n.e
if(a7){s.b_(-32,16,k.a)
r.b_(-32,8,k.b)
q.b_(-32,8,k.c)}else if(p===0){o=s.a
l=s.d+-33
J.aJ(o,l,l+21,127)
l=r.a
o=r.d+-33
J.aJ(l,o,o+9,127)
o=q.a
l=q.d+-33
J.aJ(o,l,l+9,127)}o=n.b
o===$&&A.c("isIntra4x4")
if(o){h=A.j(s,a4,-16)
g=h.bR()
if(a7){o=a3.at
o.toString
if(p>=o-1){o=k.a[15]
l=h.a
f=h.d
J.aJ(l,f,f+4,o)}else{o=a3.k2
l=p+1
if(!(l<o.length))return A.a(o,l)
h.b_(0,4,o[l].a)}}o=g.length
if(0>=o)return A.a(g,0)
e=g[0]
if(96>=o)return A.a(g,96)
g[96]=e
g[64]=e
g[32]=e
for(o=n.c,d=0;d<16;++d,i=i<<2>>>0){c=A.j(s,a4,B.at[d])
l=o[d]
if(!(l<10))return A.a(B.aF,l)
B.aF[l].$1(c)
i.toString
l=d*16
a3.dM(i,new A.a3(j,l,384,l,!1),c)}}else{o=A.lN(p,a6,n.c[0])
o.toString
if(!(o<7))return A.a(B.ae,o)
B.ae[o].$1(s)
if(i!==0)for(d=0;d<16;++d,i=i<<2>>>0){c=A.j(s,a4,B.at[d])
i.toString
o=d*16
a3.dM(i,new A.a3(j,o,384,o,!1),c)}}o=n.f
o===$&&A.c("nonZeroUV")
l=A.lN(p,a6,n.d)
l.toString
if(!(l<7))return A.a(B.Q,l)
B.Q[l].$1(r)
B.Q[l].$1(q)
b=new A.a3(j,256,384,256,!1)
if((o&255)!==0){l=a3.e
if((o&170)!==0){l===$&&A.c(a5)
l.aF(b,r)
l.aF(A.j(b,a4,16),A.j(r,a4,4))
f=A.j(b,a4,32)
a=A.j(r,a4,128)
l.aF(f,a)
l.aF(A.j(f,a4,16),A.j(a,a4,4))}else{l===$&&A.c(a5)
l.f0(b,r)}}a0=new A.a3(j,320,384,320,!1)
o=o>>>8
if((o&255)!==0){l=a3.e
if((o&170)!==0){l===$&&A.c(a5)
l.aF(a0,q)
l.aF(A.j(a0,a4,16),A.j(q,a4,4))
o=A.j(a0,a4,32)
f=A.j(q,a4,128)
l.aF(o,f)
l.aF(A.j(o,a4,16),A.j(f,a4,4))}else{l===$&&A.c(a5)
l.f0(a0,q)}}o=a3.ax
o.toString
if(a6<o-1){B.e.U(k.a,0,16,s.S(),480)
B.e.U(k.b,0,8,r.S(),224)
B.e.U(k.c,0,8,q.S(),224)}a1=p*16
a2=p*8
for(m=0;m<16;++m){o=a3.p4
o.toString
l=a3.p1
l===$&&A.c("_cacheY")
l.am(a1+m*o,16,s,m*32)}for(m=0;m<8;++m){o=a3.R8
o.toString
l=a3.p2
l===$&&A.c("_cacheU")
f=m*32
l.am(a2+m*o,8,r,f)
o=a3.R8
o.toString
l=a3.p3
l===$&&A.c("_cacheV")
l.am(a2+m*o,8,q,f)}++p}},
dM(a,b,c){var s,r,q,p,o,n,m,l,k="_dsp"
switch(a>>>30){case 3:s=this.e
s===$&&A.c(k)
s.kC(b,c,!1)
break
case 2:this.e===$&&A.c(k)
s=b.a
r=b.d
q=s.length
if(!(r>=0&&r<q))return A.a(s,r)
p=s[r]+4
r+=4
if(!(r<q))return A.a(s,r)
o=B.a.X(B.a.i(s[r]*35468,16),32)
r=b.a
s=b.d+4
if(!(s>=0&&s<r.length))return A.a(r,s)
n=B.a.X(B.a.i(r[s]*85627,16),32)
s=b.a
r=b.d+1
if(!(r>=0&&r<s.length))return A.a(s,r)
m=B.a.X(B.a.i(s[r]*35468,16),32)
r=b.a
s=b.d+1
if(!(s>=0&&s<r.length))return A.a(r,s)
l=B.a.X(B.a.i(r[s]*85627,16),32)
A.ii(c,0,p+n,l,m)
A.ii(c,1,p+o,l,m)
A.ii(c,2,p-o,l,m)
A.ii(c,3,p-n,l,m)
break
case 1:s=this.e
s===$&&A.c(k)
s.bS(b,c)
break
default:break}},
hI(a,b){var s,r,q,p,o,n,m,l,k,j,i,h=this,g=null,f="_dsp",e=h.p4,d=h.k4
d===$&&A.c("_fInfo")
if(!(a>=0&&a<d.length))return A.a(d,a)
d=d[a]
d.toString
s=h.p1
s===$&&A.c("_cacheY")
r=A.j(s,g,a*16)
q=d.b
p=d.a
if(p===0)return
if(h.au===1){if(a>0){s=h.e
s===$&&A.c(f)
e.toString
s.dg(r,e,p+4)}if(d.c){s=h.e
s===$&&A.c(f)
e.toString
s.fe(r,e,p)}if(b>0){s=h.e
s===$&&A.c(f)
e.toString
s.dh(r,e,p+4)}if(d.c){d=h.e
d===$&&A.c(f)
e.toString
d.ff(r,e,p)}}else{o=h.R8
s=h.p2
s===$&&A.c("_cacheU")
n=a*8
m=A.j(s,g,n)
s=h.p3
s===$&&A.c("_cacheV")
l=A.j(s,g,n)
k=d.d
if(a>0){s=h.e
s===$&&A.c(f)
e.toString
n=p+4
s.bf(r,1,e,16,n,q,k)
s=h.e
o.toString
s.bf(m,1,o,8,n,q,k)
s.bf(l,1,o,8,n,q,k)}if(d.c){s=h.e
s===$&&A.c(f)
e.toString
s.jY(r,e,p,q,k)
s=h.e
o.toString
j=A.j(m,g,4)
i=A.j(l,g,4)
s.be(j,1,o,8,p,q,k)
s.be(i,1,o,8,p,q,k)}if(b>0){s=h.e
s===$&&A.c(f)
e.toString
n=p+4
s.bf(r,e,1,16,n,q,k)
s=h.e
o.toString
s.bf(m,o,1,8,n,q,k)
s.bf(l,o,1,8,n,q,k)}if(d.c){d=h.e
d===$&&A.c(f)
e.toString
d.kG(r,e,p,q,k)
d=h.e
o.toString
s=4*o
j=A.j(m,g,s)
i=A.j(l,g,s)
d.be(j,o,1,8,p,q,k)
d.be(i,o,1,8,p,q,k)}}},
hU(){var s,r=this,q=r.ay
q===$&&A.c("_tlMbX")
s=q
while(!0){q=r.CW
q.toString
if(!(s<q))break
r.hI(s,r.y2);++s}},
hV(a1){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b=this,a=null,a0=b.au
a0.toString
if(!(a0<3))return A.a(B.y,a0)
s=B.y[a0]
a0=b.p4
a0.toString
r=s*a0
a0=b.R8
a0.toString
q=(s/2|0)*a0
a0=b.p1
a0===$&&A.c("_cacheY")
p=-r
o=A.j(a0,a,p)
a0=b.p2
a0===$&&A.c("_cacheU")
n=-q
m=A.j(a0,a,n)
a0=b.p3
a0===$&&A.c("_cacheV")
l=A.j(a0,a,n)
k=b.y2
a0=b.cx
a0.toString
j=k*16
i=(k+1)*16
if(a1)b.hU()
if(k!==0){j-=s
b.to=A.j(o,a,0)
b.x1=A.j(m,a,0)
b.x2=A.j(l,a,0)}else{b.to=A.j(b.p1,a,0)
b.x1=A.j(b.p2,a,0)
b.x2=A.j(b.p3,a,0)}a0=k<a0-1
if(a0)i-=s
h=b.as
h.toString
if(i>h)i=h
b.xr=null
if(b.aZ!=null&&j<i){h=b.xr=b.hA(j,i-j)
if(h==null)return!1}else h=a
g=b.Q
g.toString
if(j<g){f=g-j
e=b.to
e===$&&A.c("_y")
d=e.d
c=b.p4
c.toString
e.d=d+c*f
c=b.x1
c===$&&A.c("_u")
d=c.d
e=b.R8
e.toString
e*=B.a.i(f,1)
c.d=d+e
d=b.x2
d===$&&A.c("_v")
d.d+=e
if(h!=null){e=h.d
d=b.b.a
if(typeof d!=="number")return d.ap()
h.d=e+d*f}j=g}if(j<i){e=b.to
e===$&&A.c("_y")
d=e.d
c=b.y
c===$&&A.c("_cropLeft")
e.d=d+c
d=b.x1
d===$&&A.c("_u")
e=c>>>1
d.d=d.d+e
d=b.x2
d===$&&A.c("_v")
d.d+=e
if(h!=null)h.d+=c
h=b.z
h===$&&A.c("_cropRight")
b.iJ(j-g,h-c,i-j)}if(a0){a0=b.p1
h=b.p4
h.toString
a0.am(p,r,o,16*h)
h=b.p2
p=b.R8
p.toString
h.am(n,q,m,8*p)
p=b.p3
h=b.R8
h.toString
p.am(n,q,l,8*h)}return!0},
iJ(a,b,c){if(b<=0||c<=0)return!1
this.hK(a,b,c)
this.hJ(a,b,c)
return!0},
cz(a){var s
if((a&-4194304)>>>0===0)s=B.a.i(a,14)
else s=a<0?0:255
return s},
cg(a,b,c,d){var s=19077*a
d.h(0,0,this.cz(s+26149*c+-3644112))
d.h(0,1,this.cz(s-6419*b-13320*c+2229552))
d.h(0,2,this.cz(s+33050*b+-4527440))},
cf(a6,a7,a8,a9,b0,b1,b2,b3,b4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a=this,a0=null,a1=new A.ir(),a2=b4-1,a3=B.a.i(a2,1),a4=a8.a,a5=a8.d
if(!(a5>=0&&a5<a4.length))return A.a(a4,a5)
a5=a4[a5]
a4=a9.a
s=a9.d
if(!(s>=0&&s<a4.length))return A.a(a4,s)
r=a1.$2(a5,a4[s])
s=b0.a
a4=b0.d
if(!(a4>=0&&a4<s.length))return A.a(s,a4)
a4=s[a4]
s=b1.a
a5=b1.d
if(!(a5>=0&&a5<s.length))return A.a(s,a5)
q=a1.$2(a4,s[a5])
p=B.a.i(3*r+q+131074,2)
a5=a6.a
s=a6.d
if(!(s>=0&&s<a5.length))return A.a(a5,s)
a.cg(a5[s],p&255,p>>>16,b2)
b2.h(0,3,255)
a4=a7!=null
if(a4){p=B.a.i(3*q+r+131074,2)
a5=a7.a
s=a7.d
if(!(s>=0&&s<a5.length))return A.a(a5,s)
s=a5[s]
b3.toString
a.cg(s,p&255,p>>>16,b3)
b3.h(0,3,255)}for(o=1;o<=a3;++o,q=l,r=m){a5=a8.a
s=a8.d+o
if(!(s>=0&&s<a5.length))return A.a(a5,s)
s=a5[s]
a5=a9.a
n=a9.d+o
if(!(n>=0&&n<a5.length))return A.a(a5,n)
m=a1.$2(s,a5[n])
n=b0.a
a5=b0.d+o
if(!(a5>=0&&a5<n.length))return A.a(n,a5)
a5=n[a5]
n=b1.a
s=b1.d+o
if(!(s>=0&&s<n.length))return A.a(n,s)
l=a1.$2(a5,n[s])
k=r+m+q+l+524296
j=B.a.i(k+2*(m+q),3)
i=B.a.i(k+2*(r+l),3)
p=B.a.i(j+r,1)
h=B.a.i(i+m,1)
s=2*o
n=s-1
a5=a6.a
g=a6.d+n
if(!(g>=0&&g<a5.length))return A.a(a5,g)
g=a5[g]
a5=p&255
f=p>>>16
e=n*4
d=A.j(b2,a0,e)
g=19077*g
c=g+26149*f+-3644112
if((c&-4194304)>>>0===0)b=B.a.i(c,14)
else b=c<0?0:255
J.n(d.a,d.d,b)
f=g-6419*a5-13320*f+2229552
if((f&-4194304)>>>0===0)b=B.a.i(f,14)
else b=f<0?0:255
J.n(d.a,d.d+1,b)
a5=g+33050*a5+-4527440
if((a5&-4194304)>>>0===0)b=B.a.i(a5,14)
else b=a5<0?0:255
J.n(d.a,d.d+2,b)
J.n(d.a,d.d+3,255)
a5=s-0
g=a6.a
f=a6.d+a5
if(!(f>=0&&f<g.length))return A.a(g,f)
f=g[f]
g=h&255
d=h>>>16
a5=A.j(b2,a0,a5*4)
f=19077*f
c=f+26149*d+-3644112
if((c&-4194304)>>>0===0)b=B.a.i(c,14)
else b=c<0?0:255
J.n(a5.a,a5.d,b)
d=f-6419*g-13320*d+2229552
if((d&-4194304)>>>0===0)b=B.a.i(d,14)
else b=d<0?0:255
J.n(a5.a,a5.d+1,b)
g=f+33050*g+-4527440
if((g&-4194304)>>>0===0)b=B.a.i(g,14)
else b=g<0?0:255
J.n(a5.a,a5.d+2,b)
J.n(a5.a,a5.d+3,255)
if(a4){p=B.a.i(i+q,1)
h=B.a.i(j+l,1)
a5=a7.a
n=a7.d+n
if(!(n>=0&&n<a5.length))return A.a(a5,n)
n=a5[n]
a5=p&255
g=p>>>16
b3.toString
e=A.j(b3,a0,e)
n=19077*n
f=n+26149*g+-3644112
if((f&-4194304)>>>0===0)b=B.a.i(f,14)
else b=f<0?0:255
J.n(e.a,e.d,b)
g=n-6419*a5-13320*g+2229552
if((g&-4194304)>>>0===0)b=B.a.i(g,14)
else b=g<0?0:255
J.n(e.a,e.d+1,b)
a5=n+33050*a5+-4527440
if((a5&-4194304)>>>0===0)b=B.a.i(a5,14)
else b=a5<0?0:255
J.n(e.a,e.d+2,b)
J.n(e.a,e.d+3,255)
a5=a7.a
n=a7.d+s
if(!(n>=0&&n<a5.length))return A.a(a5,n)
n=a5[n]
a5=h&255
g=h>>>16
s=A.j(b3,a0,s*4)
n=19077*n
f=n+26149*g+-3644112
if((f&-4194304)>>>0===0)b=B.a.i(f,14)
else b=f<0?0:255
J.n(s.a,s.d,b)
g=n-6419*a5-13320*g+2229552
if((g&-4194304)>>>0===0)b=B.a.i(g,14)
else b=g<0?0:255
J.n(s.a,s.d+1,b)
a5=n+33050*a5+-4527440
if((a5&-4194304)>>>0===0)b=B.a.i(a5,14)
else b=a5<0?0:255
J.n(s.a,s.d+2,b)
J.n(s.a,s.d+3,255)}}if((b4&1)===0){p=B.a.i(3*r+q+131074,2)
a5=a6.a
s=a6.d+a2
if(!(s>=0&&s<a5.length))return A.a(a5,s)
s=a5[s]
a5=a2*4
n=A.j(b2,a0,a5)
a.cg(s,p&255,p>>>16,n)
n.h(0,3,255)
if(a4){p=B.a.i(3*q+r+131074,2)
a4=a7.a
a2=a7.d+a2
if(!(a2>=0&&a2<a4.length))return A.a(a4,a2)
a2=a4[a2]
b3.toString
a5=A.j(b3,a0,a5)
a.cg(a2,p&255,p>>>16,a5)
a5.h(0,3,255)}}},
hJ(a,b,c){var s,r,q,p,o,n,m,l,k,j=this,i=j.xr
if(i==null)return
s=j.b
r=s.a
if(typeof r!=="number")return r.ap()
q=r*4
p=A.j(i,null,0)
if(a===0){o=c-1
n=a}else{n=a-1
p.d-=r
o=c}m=A.l(j.d.aw(),!1,null,n*q+3)
i=j.Q
i.toString
r=j.as
if(i+a+c===r){r.toString
o=r-i-n}for(l=0;l<o;++l){for(k=0;k<b;++k){i=p.a
r=p.d+k
if(!(r>=0&&r<i.length))return A.a(i,r)
r=i[r]
J.n(m.a,m.d+4*k,r&255)}i=p.d
r=s.a
if(typeof r!=="number")return A.D(r)
p.d=i+r
m.d+=q}},
hK(a,b,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=this,e=null,d=f.d.aw(),c=f.b.a
if(typeof c!=="number")return A.D(c)
s=A.l(d,!1,e,a*c*4)
d=f.to
d===$&&A.c("_y")
r=A.j(d,e,0)
d=f.x1
d===$&&A.c("_u")
q=A.j(d,e,0)
d=f.x2
d===$&&A.c("_v")
p=A.j(d,e,0)
o=a+a0
n=B.a.i(b+1,1)
m=c*4
c=f.rx
c===$&&A.c("_tmpU")
l=A.j(c,e,0)
c=f.ry
c===$&&A.c("_tmpV")
k=A.j(c,e,0)
if(a===0){f.cf(r,e,q,p,q,p,s,e,b)
j=a0}else{d=f.RG
d===$&&A.c("_tmpY")
f.cf(d,r,l,k,q,p,A.j(s,e,-m),s,b)
j=a0+1}l.sd0(0,q.a)
k.sd0(0,p.a)
for(d=2*m,c=-m,i=a;i+=2,i<o;){l.d=q.d
k.d=p.d
h=q.d
g=f.R8
g.toString
q.d=h+g
p.d+=g
s.d+=d
g=r.d
h=f.p4
h.toString
r.d=g+2*h
f.cf(A.j(r,e,-h),r,l,k,q,p,A.j(s,e,c),s,b)}d=r.d
c=f.p4
c.toString
r.d=d+c
d=f.Q
d.toString
c=f.as
c.toString
if(d+o<c){d=f.RG
d===$&&A.c("_tmpY")
d.b_(0,b,r)
f.rx.b_(0,n,q)
f.ry.b_(0,n,p);--j}else if((o&1)===0)f.cf(r,e,q,p,q,p,A.j(s,e,m),e,b)
return j},
hA(a,b){var s,r,q,p,o,n,m,l,k,j,i=this,h=null,g="_alphaPlane",f=i.b,e=f.a,d=f.b
if(a<0||b<=0||a+b>d)return h
if(a===0){f=e*d
i.aM=new Uint8Array(f)
s=i.aZ
r=new A.is(s,e,d)
q=s.t()
r.d=q&3
r.e=B.a.i(q,2)&3
r.f=B.a.i(q,4)&3
r.r=B.a.i(q,6)&3
if(r.geO()){p=r.d
if(p===0){if(s.c-s.d<f)r.r=1}else if(p===1){o=new A.dj(A.b([],t.J))
o.a=e
o.b=d
f=A.b([],t.W)
p=A.b([],t.ip)
n=new Uint32Array(2)
m=new A.fe(s,n)
n=m.d=A.z(n.buffer,0,h)
l=s.t()
k=n.length
if(0>=k)return A.a(n,0)
n[0]=l
l=s.t()
if(1>=k)return A.a(n,1)
n[1]=l
l=s.t()
if(2>=k)return A.a(n,2)
n[2]=l
l=s.t()
if(3>=k)return A.a(n,3)
n[3]=l
l=s.t()
if(4>=k)return A.a(n,4)
n[4]=l
l=s.t()
if(5>=k)return A.a(n,5)
n[5]=l
l=s.t()
if(6>=k)return A.a(n,6)
n[6]=l
s=s.t()
if(7>=k)return A.a(n,7)
n[7]=s
p=r.x=new A.eo(m,o,f,p)
p.db=e
p.bw(e,d,!0)
f=r.x
s=f.ax
p=s.length
if(p===1){if(0>=p)return A.a(s,0)
f=s[0].a===3&&f.ie()}else f=!1
if(f){r.y=!0
f=r.x
s=f.c
p=s.a
s=s.b
if(typeof p!=="number")return p.ap()
if(typeof s!=="number")return A.D(s)
j=p*s
f.cx=0
s=B.a.I(j,4)
s=new Uint8Array(j+(4-s))
f.CW=s
f.ch=A.k4(s.buffer,0,h)}else{r.y=!1
r.x.du()}}else r.r=1}i.aL=r}f=i.aL
f===$&&A.c("_alpha")
if(!f.w){s=i.aM
s===$&&A.c(g)
if(!f.jG(a,b,s))return h}f=i.aM
f===$&&A.c(g)
return A.l(f,!1,h,a*e)},
iA(a8,a9){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4=this,a5=a4.fr.b,a6=a4.dy,a7=a4.k1
a7===$&&A.c("_segment")
if(!(a7<4))return A.a(a6,a7)
s=a6[a7]
a7=a4.ai
a7===$&&A.c("_mbData")
a6=a4.y1
if(!(a6<a7.length))return A.a(a7,a6)
r=a7[a6]
q=A.l(r.a,!1,null,0)
a6=a4.k3
a6===$&&A.c("_mbInfo")
if(0>=a6.length)return A.a(a6,0)
p=a6[0]
q.ka(0,q.c-q.d,0)
a6=r.b
a6===$&&A.c("isIntra4x4")
if(!a6){o=A.l(new Int16Array(16),!1,null,0)
a6=a8.b
a7=p.b
if(1>=a5.length)return A.a(a5,1)
n=a4.cL(a9,a5[1],a6+a7,s.b,0,o)
a8.b=p.b=n>0?1:0
if(n>1)a4.ji(o,q)
else{a6=o.a
a7=o.d
if(!(a7>=0&&a7<a6.length))return A.a(a6,a7)
m=B.a.i(a6[a7]+3,3)
for(l=0;l<256;l+=16)J.n(q.a,q.d+l,m)}k=a5[0]
j=1}else{if(3>=a5.length)return A.a(a5,3)
k=a5[3]
j=0}i=a8.a&15
h=p.a&15
for(g=0,f=0;f<4;++f){e=h&1
for(d=0,c=0;c<4;++c,d=b){n=a4.cL(a9,k,e+(i&1),s.a,j,q)
e=n>j?1:0
i=i>>>1|e<<7
a6=q.a
a7=q.d
if(!(a7>=0&&a7<a6.length))return A.a(a6,a7)
a6=a6[a7]!==0?1:0
if(n>3)a6=3
else if(n>1)a6=2
b=d<<2|a6
q.d=a7+16}i=i>>>4
h=h>>>1|e<<7
g=(g<<8|d)>>>0}a=h>>>4
for(a6=a5.length,a0=i,a1=0,a2=0;a2<4;a2+=2){a7=4+a2
i=B.a.L(a8.a,a7)
h=B.a.L(p.a,a7)
for(d=0,f=0;f<2;++f){e=h&1
for(c=0;c<2;++c,d=b){if(2>=a6)return A.a(a5,2)
n=a4.cL(a9,a5[2],e+(i&1),s.c,0,q)
e=n>0?1:0
i=i>>>1|e<<3
a7=q.a
a3=q.d
if(!(a3>=0&&a3<a7.length))return A.a(a7,a3)
a7=a7[a3]!==0?1:0
if(n>3)a7=3
else if(n>1)a7=2
b=(d<<2|a7)>>>0
q.d=a3+16}i=i>>>2
h=h>>>1|e<<5}a1=(a1|B.a.B(d,4*a2))>>>0
a0=(a0|B.a.B(i<<4>>>0,a2))>>>0
a=(a|B.a.B(h&240,a2))>>>0}a8.a=a0
p.a=a
r.e=g
r.f=a1
if((a1&43690)===0)s.toString
return(g|a1)>>>0===0},
ji(a,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b=new Int32Array(16)
for(s=a.a,r=a.d,q=s.length,p=0;p<4;++p){o=r+p
if(!(o>=0&&o<q))return A.a(s,o)
o=s[o]
n=12+p
m=r+n
if(!(m>=0&&m<q))return A.a(s,m)
m=s[m]
l=o+m
k=4+p
j=r+k
if(!(j>=0&&j<q))return A.a(s,j)
j=s[j]
i=8+p
h=r+i
if(!(h>=0&&h<q))return A.a(s,h)
h=s[h]
g=j+h
f=j-h
e=o-m
if(!(p<16))return A.a(b,p)
b[p]=l+g
if(!(i<16))return A.a(b,i)
b[i]=l-g
b[k]=e+f
if(!(n<16))return A.a(b,n)
b[n]=e-f}for(d=0,p=0;p<4;++p){s=p*4
if(!(s<16))return A.a(b,s)
c=b[s]+3
r=3+s
if(!(r<16))return A.a(b,r)
r=b[r]
l=c+r
q=1+s
if(!(q<16))return A.a(b,q)
q=b[q]
s=2+s
if(!(s<16))return A.a(b,s)
s=b[s]
g=q+s
f=q-s
e=c-r
r=B.a.i(l+g,3)
J.n(a0.a,a0.d+d,r)
r=B.a.i(e+f,3)
J.n(a0.a,a0.d+(d+16),r)
r=B.a.i(l-g,3)
J.n(a0.a,a0.d+(d+32),r)
r=B.a.i(e-f,3)
J.n(a0.a,a0.d+(d+48),r)
d+=64}},
i1(a,b){var s,r,q,p,o,n,m
t.L.a(b)
if(a.J(b[3])===0)s=a.J(b[4])===0?2:3+a.J(b[5])
else if(a.J(b[6])===0)s=a.J(b[7])===0?5+a.J(159):7+2*a.J(165)+a.J(145)
else{r=a.J(b[8])
q=9+r
if(!(q<11))return A.a(b,q)
p=2*r+a.J(b[q])
if(!(p<4))return A.a(B.aE,p)
o=B.aE[p]
for(n=o.length,s=0,m=0;m<n;++m)s+=s+a.J(o[m])
s+=3+B.a.B(8,p)}return s},
cL(a,b,c,d,e,f){var s,r,q,p,o,n,m,l,k,j
t.ac.a(b)
t.L.a(d)
s=b.length
if(!(e<s))return A.a(b,e)
r=b[e].a
if(!(c<r.length))return A.a(r,c)
q=r[c]
for(;e<16;e=p){if(a.J(q[0])===0)return e
for(;a.J(q[1])===0;){++e
if(!(e>=0&&e<17))return A.a(B.E,e)
r=B.E[e]
if(!(r<s))return A.a(b,r)
r=b[r].a
if(0>=r.length)return A.a(r,0)
q=r[0]
if(e===16)return 16}p=e+1
if(!(p>=0&&p<17))return A.a(B.E,p)
r=B.E[p]
if(!(r<s))return A.a(b,r)
o=b[r].a
r=o.length
if(a.J(q[2])===0){if(1>=r)return A.a(o,1)
q=o[1]
n=1}else{n=this.i1(a,q)
if(2>=r)return A.a(o,2)
q=o[2]}if(!(e>=0&&e<16))return A.a(B.au,e)
r=B.au[e]
m=a.b
m===$&&A.c("_range")
l=a.dB(B.a.i(m,1))
m=a.b
if(m>>>0!==m||m>=128)return A.a(B.C,m)
k=B.C[m]
a.b=B.aH[m]
m=a.d
m===$&&A.c("_bits")
a.d=m-k
m=l!==0?-n:n
j=d[e>0?1:0]
J.n(f.a,f.d+r,m*j)}return 16},
iw(){var s,r,q,p,o,n,m,l,k,j,i=this,h=i.y1,g=4*h,f=i.go,e=i.id,d=i.ai
d===$&&A.c("_mbData")
if(!(h<d.length))return A.a(d,h)
s=d[h]
h=i.c
h===$&&A.c("br")
h=h.J(145)===0
s.b=h
if(!h){if(i.c.J(156)!==0)r=i.c.J(128)!==0?1:3
else r=i.c.J(163)!==0?2:0
s.c[0]=r
f.toString
B.e.ak(f,g,g+4,r)
B.e.ak(e,0,4,r)}else{q=s.c
for(p=0,o=0;o<4;++o,p=j){r=e[o]
for(n=0;n<4;++n){h=g+n
if(!(h<f.length))return A.a(f,h)
d=f[h]
if(!(d<10))return A.a(B.ad,d)
d=B.ad[d]
if(!(r>=0&&r<10))return A.a(d,r)
m=d[r]
l=i.c.J(m[0])
if(!(l<18))return A.a(B.J,l)
k=B.J[l]
for(;k>0;){d=i.c
if(!(k<9))return A.a(m,k)
d=2*k+d.J(m[k])
if(!(d>=0&&d<18))return A.a(B.J,d)
k=B.J[d]}r=-k
f[h]=r}j=p+4
f.toString
B.e.U(q,p,j,f,g)
if(!(o<4))return A.a(e,o)
e[o]=r}}if(i.c.J(142)===0)h=0
else if(i.c.J(114)===0)h=2
else h=i.c.J(183)!==0?1:3
s.d=h},
sh1(a){this.k2=t.f4.a(a)},
sh0(a){this.k3=t.jt.a(a)},
sfY(a){this.k4=t.kb.a(a)},
sh_(a){this.ai=t.as.a(a)},
sfZ(a){this.ab=t.mL.a(a)}}
A.ir.prototype={
$2(a,b){return(a|b<<16)>>>0},
$S:40}
A.dc.prototype={
E(a){var s,r
for(s=0;r=a-1,a>0;a=r)s=(s|B.a.D(this.J(128),r))>>>0
return s},
bs(a){var s=this.E(a)
return this.E(1)===1?-s:s},
J(a){var s,r=this,q=r.b
q===$&&A.c("_range")
s=r.dB(B.a.i(q*a,8))
if(r.b<=126)r.je()
return s},
dB(a){var s,r,q,p,o,n=this,m="_value",l=n.d
l===$&&A.c("_bits")
if(l<0){s=n.a
r=s.c
q=s.d
if(r-q>=1){p=s.t()
l=n.c
l===$&&A.c(m)
n.c=(p|l<<8)>>>0
l=n.d+8
n.d=l
o=l}else{if(q<r){l=s.t()
s=n.c
s===$&&A.c(m)
n.c=(l|s<<8)>>>0
s=n.d+8
n.d=s
l=s}else if(!n.e){s=n.c
s===$&&A.c(m)
n.c=s<<8>>>0
l+=8
n.d=l
n.e=!0}o=l}}else o=l
l=n.c
l===$&&A.c(m)
if(B.a.a8(l,o)>a){s=n.b
s===$&&A.c("_range")
r=a+1
n.b=s-r
n.c=l-B.a.D(r,o)
return 1}else{n.b=a
return 0}},
je(){var s,r=this,q=r.b
q===$&&A.c("_range")
if(!(q>=0&&q<128))return A.a(B.C,q)
s=B.C[q]
r.b=B.aH[q]
q=r.d
q===$&&A.c("_bits")
r.d=q-s}}
A.id.prototype={
dh(a,b,c){var s,r=A.j(a,null,0)
for(s=0;s<16;++s){r.d=a.d+s
if(this.e5(r,b,c))this.c3(r,b)}},
dg(a,b,c){var s,r=A.j(a,null,0)
for(s=0;s<16;++s){r.d=a.d+s*b
if(this.e5(r,1,c))this.c3(r,1)}},
ff(a,b,c){var s,r,q=A.j(a,null,0)
for(s=4*b,r=3;r>0;--r){q.d+=s
this.dh(q,b,c)}},
fe(a,b,c){var s,r=A.j(a,null,0)
for(s=3;s>0;--s){r.d+=4
this.dg(r,b,c)}},
kG(a,b,c,d,e){var s,r,q=A.j(a,null,0)
for(s=4*b,r=3;r>0;--r){q.d+=s
this.be(q,b,1,16,c,d,e)}},
jY(a,b,c,d,e){var s,r=A.j(a,null,0)
for(s=3;s>0;--s){r.d+=4
this.be(r,1,b,16,c,d,e)}},
bf(a1,a2,a3,a4,a5,a6,a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=A.j(a1,null,0)
for(s=-3*a2,r=-2*a2,q=-a2,p=2*a2;o=a4-1,a4>0;a4=o){if(this.e6(a0,a2,a5,a6))if(this.dX(a0,a2,a7))this.c3(a0,a2)
else{n=a0.a
m=a0.d
l=m+s
k=n.length
if(!(l>=0&&l<k))return A.a(n,l)
j=n[l]
i=m+r
if(!(i>=0&&i<k))return A.a(n,i)
i=n[i]
h=m+q
if(!(h>=0&&h<k))return A.a(n,h)
h=n[h]
if(!(m>=0&&m<k))return A.a(n,m)
g=n[m]
f=m+a2
if(!(f<k))return A.a(n,f)
f=n[f]
m+=p
if(!(m<k))return A.a(n,m)
m=n[m]
k=$.jQ()
e=1020+i-f
k.toString
if(!(e>=0&&e<2041))return A.a(k,e)
e=1020+3*(g-h)+k[e]
if(!(e>=0&&e<2041))return A.a(k,e)
d=k[e]
e=B.a.i(27*d+63,7)
c=(e&2147483647)-((e&2147483648)>>>0)
e=B.a.i(18*d+63,7)
b=(e&2147483647)-((e&2147483648)>>>0)
e=B.a.i(9*d+63,7)
a=(e&2147483647)-((e&2147483648)>>>0)
e=$.af()
j=255+j+a
e.toString
if(!(j>=0&&j<766))return A.a(e,j)
J.n(n,l,e[j])
j=$.af()
i=255+i+b
j.toString
if(!(i>=0&&i<766))return A.a(j,i)
i=j[i]
J.n(a0.a,a0.d+r,i)
i=$.af()
h=255+h+c
i.toString
if(!(h>=0&&h<766))return A.a(i,h)
h=i[h]
J.n(a0.a,a0.d+q,h)
h=$.af()
g=255+g-c
h.toString
if(!(g>=0&&g<766))return A.a(h,g)
g=h[g]
J.n(a0.a,a0.d,g)
g=$.af()
f=255+f-b
g.toString
if(!(f>=0&&f<766))return A.a(g,f)
f=g[f]
J.n(a0.a,a0.d+a2,f)
f=$.af()
m=255+m-a
f.toString
if(!(m>=0&&m<766))return A.a(f,m)
m=f[m]
J.n(a0.a,a0.d+p,m)}a0.d+=a3}},
be(a,b,c,a0,a1,a2,a3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=A.j(a,null,0)
for(s=-2*b,r=-b;q=a0-1,a0>0;a0=q){if(this.e6(d,b,a1,a2))if(this.dX(d,b,a3))this.c3(d,b)
else{p=d.a
o=d.d
n=o+s
m=p.length
if(!(n>=0&&n<m))return A.a(p,n)
l=p[n]
k=o+r
if(!(k>=0&&k<m))return A.a(p,k)
k=p[k]
if(!(o>=0&&o<m))return A.a(p,o)
j=p[o]
o+=b
if(!(o<m))return A.a(p,o)
o=p[o]
i=3*(j-k)
m=$.fH()
h=B.a.i(i+4,3)
h=112+((h&2147483647)-((h&2147483648)>>>0))
m.toString
if(!(h>=0&&h<225))return A.a(m,h)
g=m[h]
h=B.a.i(i+3,3)
h=112+((h&2147483647)-((h&2147483648)>>>0))
if(!(h>=0&&h<225))return A.a(m,h)
f=m[h]
h=B.a.i(g+1,1)
e=(h&2147483647)-((h&2147483648)>>>0)
h=$.af()
l=255+l+e
h.toString
if(!(l>=0&&l<766))return A.a(h,l)
J.n(p,n,h[l])
l=$.af()
k=255+k+f
l.toString
if(!(k>=0&&k<766))return A.a(l,k)
k=l[k]
J.n(d.a,d.d+r,k)
k=$.af()
j=255+j-g
k.toString
if(!(j>=0&&j<766))return A.a(k,j)
j=k[j]
J.n(d.a,d.d,j)
j=$.af()
o=255+o-e
j.toString
if(!(o>=0&&o<766))return A.a(j,o)
o=j[o]
J.n(d.a,d.d+b,o)}d.d+=c}},
c3(a,b){var s,r,q,p,o,n,m=a.a,l=a.d,k=l+-2*b,j=m.length
if(!(k>=0&&k<j))return A.a(m,k)
k=m[k]
s=-b
r=l+s
if(!(r>=0&&r<j))return A.a(m,r)
r=m[r]
if(!(l>=0&&l<j))return A.a(m,l)
q=m[l]
l+=b
if(!(l<j))return A.a(m,l)
l=m[l]
m=$.jQ()
l=1020+k-l
m.toString
if(!(l>=0&&l<2041))return A.a(m,l)
p=3*(q-r)+m[l]
l=$.fH()
m=112+B.a.X(B.a.i(p+4,3),32)
l.toString
if(!(m>=0&&m<225))return A.a(l,m)
o=l[m]
m=$.fH()
l=112+B.a.X(B.a.i(p+3,3),32)
m.toString
if(!(l>=0&&l<225))return A.a(m,l)
n=m[l]
l=$.af()
r=255+r+n
l.toString
if(!(r>=0&&r<766))return A.a(l,r)
a.h(0,s,l[r])
r=$.af()
q=255+q-o
r.toString
if(!(q>=0&&q<766))return A.a(r,q)
a.h(0,0,r[q])},
dX(a,b,c){var s,r,q=a.a,p=a.d,o=p+-2*b,n=q.length
if(!(o>=0&&o<n))return A.a(q,o)
o=q[o]
s=p+-b
if(!(s>=0&&s<n))return A.a(q,s)
s=q[s]
if(!(p>=0&&p<n))return A.a(q,p)
r=q[p]
p+=b
if(!(p<n))return A.a(q,p)
p=q[p]
q=$.fG()
s=255+o-s
q.toString
if(!(s>=0&&s<511))return A.a(q,s)
if(q[s]<=c){p=255+p-r
if(!(p>=0&&p<511))return A.a(q,p)
p=q[p]>c
q=p}else q=!0
return q},
e5(a,b,c){var s,r,q=a.a,p=a.d,o=p+-2*b,n=q.length
if(!(o>=0&&o<n))return A.a(q,o)
o=q[o]
s=p+-b
if(!(s>=0&&s<n))return A.a(q,s)
s=q[s]
if(!(p>=0&&p<n))return A.a(q,p)
r=q[p]
p+=b
if(!(p<n))return A.a(q,p)
p=q[p]
q=$.fG()
r=255+s-r
q.toString
if(!(r>=0&&r<511))return A.a(q,r)
r=q[r]
q=$.jP()
p=255+o-p
q.toString
if(!(p>=0&&p<511))return A.a(q,p)
return 2*r+q[p]<=c},
e6(a,b,c,d){var s,r,q,p,o,n,m,l,k,j=a.a,i=a.d,h=i+-4*b,g=j.length
if(!(h>=0&&h<g))return A.a(j,h)
h=j[h]
s=i+-3*b
if(!(s>=0&&s<g))return A.a(j,s)
s=j[s]
r=i+-2*b
if(!(r>=0&&r<g))return A.a(j,r)
r=j[r]
q=i+-b
if(!(q>=0&&q<g))return A.a(j,q)
q=j[q]
if(!(i>=0&&i<g))return A.a(j,i)
p=j[i]
o=i+b
if(!(o<g))return A.a(j,o)
o=j[o]
n=i+2*b
if(!(n<g))return A.a(j,n)
n=j[n]
i+=3*b
if(!(i<g))return A.a(j,i)
i=j[i]
j=$.fG()
g=255+q-p
j.toString
if(!(g>=0&&g<511))return A.a(j,g)
g=j[g]
m=$.jP()
l=255+r
k=l-o
m.toString
if(!(k>=0&&k<511))return A.a(m,k)
if(2*g+m[k]>c)return!1
h=255+h-s
if(!(h>=0&&h<511))return A.a(j,h)
if(j[h]<=d){h=255+s-r
if(!(h>=0&&h<511))return A.a(j,h)
if(j[h]<=d){h=l-q
if(!(h>=0&&h<511))return A.a(j,h)
if(j[h]<=d){i=255+i-n
if(!(i>=0&&i<511))return A.a(j,i)
if(j[i]<=d){i=255+n-o
if(!(i>=0&&i<511))return A.a(j,i)
if(j[i]<=d){i=255+o-p
if(!(i>=0&&i<511))return A.a(j,i)
i=j[i]<=d
j=i}else j=!1}else j=!1}else j=!1}else j=!1}else j=!1
return j},
aF(a,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b=new Int32Array(16)
for(s=a.a,r=a.d,q=s.length,p=0,o=0,n=0;n<4;++n){m=r+p
if(!(m>=0&&m<q))return A.a(s,m)
m=s[m]
l=r+(p+8)
if(!(l>=0&&l<q))return A.a(s,l)
l=s[l]
k=m+l
j=m-l
l=r+(p+4)
if(!(l>=0&&l<q))return A.a(s,l)
l=s[l]
m=B.a.i(l*35468,16)
i=r+(p+12)
if(!(i>=0&&i<q))return A.a(s,i)
i=s[i]
h=B.a.i(i*85627,16)
g=(m&2147483647)-((m&2147483648)>>>0)-((h&2147483647)-((h&2147483648)>>>0))
l=B.a.i(l*85627,16)
i=B.a.i(i*35468,16)
f=(l&2147483647)-((l&2147483648)>>>0)+((i&2147483647)-((i&2147483648)>>>0))
e=o+1
if(!(o<16))return A.a(b,o)
b[o]=k+f
o=e+1
if(!(e<16))return A.a(b,e)
b[e]=j+g
e=o+1
if(!(o<16))return A.a(b,o)
b[o]=j-g
o=e+1
if(!(e<16))return A.a(b,e)
b[e]=k-f;++p}for(d=0,o=0,n=0;n<4;++n){if(!(o<16))return A.a(b,o)
c=b[o]+4
s=o+8
if(!(s<16))return A.a(b,s)
s=b[s]
k=c+s
j=c-s
s=o+4
if(!(s<16))return A.a(b,s)
s=b[s]
r=B.a.i(s*35468,16)
q=o+12
if(!(q<16))return A.a(b,q)
q=b[q]
m=B.a.i(q*85627,16)
g=(r&2147483647)-((r&2147483648)>>>0)-((m&2147483647)-((m&2147483648)>>>0))
s=B.a.i(s*85627,16)
q=B.a.i(q*35468,16)
f=(s&2147483647)-((s&2147483648)>>>0)+((q&2147483647)-((q&2147483648)>>>0))
A.bl(a0,d,0,0,k+f)
A.bl(a0,d,1,0,j+g)
A.bl(a0,d,2,0,j-g)
A.bl(a0,d,3,0,k-f);++o
d+=32}},
kC(a,b,c){this.aF(a,b)
if(c)this.aF(A.j(a,null,16),A.j(b,null,4))},
bS(a,b){var s,r,q,p=a.a,o=a.d
if(!(o>=0&&o<p.length))return A.a(p,o)
s=p[o]+4
for(r=0;r<4;++r)for(q=0;q<4;++q)A.bl(b,0,q,r,s)},
f0(a,b){var s=this,r=null,q=a.a,p=a.d
if(!(p>=0&&p<q.length))return A.a(q,p)
if(q[p]!==0)s.bS(a,b)
q=a.a
p=a.d+16
if(!(p>=0&&p<q.length))return A.a(q,p)
if(q[p]!==0)s.bS(A.j(a,r,16),A.j(b,r,4))
q=a.a
p=a.d+32
if(!(p>=0&&p<q.length))return A.a(q,p)
if(q[p]!==0)s.bS(A.j(a,r,32),A.j(b,r,128))
q=a.a
p=a.d+48
if(!(p>=0&&p<q.length))return A.a(q,p)
if(q[p]!==0)s.bS(A.j(a,r,48),A.j(b,r,132))}}
A.ij.prototype={}
A.io.prototype={}
A.iq.prototype={}
A.db.prototype={}
A.ip.prototype={}
A.ie.prototype={}
A.aW.prototype={}
A.de.prototype={}
A.fg.prototype={}
A.df.prototype={}
A.dg.prototype={}
A.dd.prototype={
bH(){var s,r=this.b
if(r.N(8)!==47)return!1
s=this.c
s.f=2
s.a=r.N(14)+1
s.b=r.N(14)+1
s.d=r.N(1)!==0
if(r.N(3)!==0)return!1
return!0},
aK(){var s,r,q,p=this,o=null
p.e=0
if(!p.bH())return o
s=p.c
p.bw(s.a,s.b,!0)
p.du()
p.d=A.T(s.a,s.b,B.f,o,o)
r=p.ch
r.toString
q=s.a
s=s.b
if(!p.cE(r,q,s,s,p.giG()))return o
return p.d},
du(){var s,r=this,q=r.c,p=q.a
q=q.b
if(typeof p!=="number")return p.ap()
if(typeof q!=="number")return A.D(q)
q=p*q+p
s=new Uint32Array(q+p*16)
r.ch=s
r.CW=A.z(s.buffer,0,null)
r.cx=q
return!0},
j7(a){var s,r,q,p,o,n,m,l=this
t.L.a(a)
s=l.b
r=s.N(2)
q=l.ay
p=B.a.B(1,r)
if((q&p)>>>0!==0)return!1
l.ay=(q|p)>>>0
o=new A.ff()
B.b.A(l.ax,o)
o.a=r
o.b=a[0]
o.c=a[1]
switch(r){case 0:case 1:s=o.e=s.N(3)+2
o.d=l.bw(A.bK(o.b,s),A.bK(o.c,s),!1)
break
case 3:n=s.N(8)+1
if(n>16)m=0
else if(n>4)m=1
else{s=n>2?2:3
m=s}B.b.h(a,0,A.bK(o.b,m))
o.e=m
o.d=l.bw(n,1,!1)
l.hO(n,o)
break
case 2:break
default:throw A.d(A.f("Invalid WebP transform type: "+r))}return!0},
bw(a,b,c){var s,r,q,p,o,n,m,l,k=this
A.o(a)
A.o(b)
if(c){for(s=k.b,r=t.t,q=b,p=a;s.N(1)!==0;){o=A.b([p,q],r)
if(!k.j7(o))throw A.d(A.f("Invalid Transform"))
p=o[0]
q=o[1]}c=!0}else{q=b
p=a}s=k.b
if(s.N(1)!==0){n=s.N(4)
if(!(n>=1&&n<=11))throw A.d(A.f("Invalid Color Cache"))}else n=0
if(!k.iX(p,q,n,c))throw A.d(A.f("Invalid Huffman Codes"))
if(n>0){s=B.a.B(1,n)
k.r=s
k.w=new A.ik(new Uint32Array(s),32-n)}else k.r=0
s=k.c
s.a=p
s.b=q
m=k.y
k.z=A.bK(p,m)
k.x=m===0?4294967295:B.a.B(1,m)-1
if(c){k.e=0
return null}l=new Uint32Array(p*q)
if(!k.cE(l,p,q,q,null))throw A.d(A.f("Failed to decode image data."))
k.e=0
return l},
cE(b0,b1,b2,b3,b4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9=this
A.o(b1)
A.o(b2)
A.o(b3)
t.bZ.a(b4)
s=a9.e
r=B.a.V(s,b1)
q=B.a.I(s,b1)
p=a9.dR(q,r)
o=a9.e
n=b1*b2
m=b1*b3
s=a9.r
l=280+s
k=s>0?a9.w:null
j=a9.x
s=b0.length
i=a9.b
h=b4!=null
g=o
while(!0){f=i.b
e=f.c
if(!(!(f.d>=e&&i.a>=64)&&o<m))break
if((q&j)>>>0===0){d=a9.bx(a9.Q,a9.z,a9.y,q,r)
f=a9.at
if(!(d<f.length))return A.a(f,d)
p=f[d]}if(i.a>=32)i.b6()
f=p.a
e=f.length
if(0>=e)return A.a(f,0)
c=f[0].b0(i)
if(c<256){if(1>=e)return A.a(f,1)
b=f[1].b0(i)
if(i.a>=32)i.b6()
if(2>=e)return A.a(f,2)
a=f[2].b0(i)
if(3>=e)return A.a(f,3)
f=B.c.m(B.a.p(f[3].b0(i),0,255))
e=B.c.m(B.a.p(b,0,255))
a0=B.c.m(B.a.p(c,0,255))
a1=B.c.m(B.a.p(a,0,255))
if(!(o>=0&&o<s))return A.a(b0,o)
b0[o]=(f<<24|e<<16|a0<<8|a1)>>>0;++o;++q
if(q>=b1){++r
if(B.a.I(r,16)===0&&h)b4.$1(r)
if(k!=null)for(f=k.b,e=k.a,a0=e.length;g<o;){if(!(g>=0))return A.a(b0,g)
a1=b0[g]
a2=B.a.a5(a1*506832829>>>0,f)
if(!(a2<a0))return A.a(e,a2)
e[a2]=a1;++g}q=0}}else if(c<280){a3=a9.c7(c-256)
if(4>=e)return A.a(f,4)
a4=f[4].b0(i)
if(i.a>=32)i.b6()
a5=a9.eb(b1,a9.c7(a4))
if(o<a5||n-o<a3)return!1
else{a6=o-a5
for(a7=0;a7<a3;++a7){f=o+a7
e=a6+a7
if(!(e>=0&&e<s))return A.a(b0,e)
e=b0[e]
if(!(f>=0&&f<s))return A.a(b0,f)
b0[f]=e}o+=a3}q+=a3
for(;q>=b1;){q-=b1;++r
if(B.a.I(r,16)===0&&h)b4.$1(r)}if(o<m){if((q&j)>>>0!==0){d=a9.bx(a9.Q,a9.z,a9.y,q,r)
f=a9.at
if(!(d<f.length))return A.a(f,d)
p=f[d]}if(k!=null)for(f=k.b,e=k.a,a0=e.length;g<o;){if(!(g>=0&&g<s))return A.a(b0,g)
a1=b0[g]
a2=B.a.a5(a1*506832829>>>0,f)
if(!(a2<a0))return A.a(e,a2)
e[a2]=a1;++g}}}else if(c<l){a2=c-280
for(;g<o;){k.toString
if(!(g>=0&&g<s))return A.a(b0,g)
f=b0[g]
a8=B.a.a5(f*506832829>>>0,k.b)
e=k.a
if(!(a8<e.length))return A.a(e,a8)
e[a8]=f;++g}f=k.a
e=f.length
if(!(a2<e))return A.a(f,a2)
a0=f[a2]
if(!(o>=0&&o<s))return A.a(b0,o)
b0[o]=a0;++o;++q
if(q>=b1){++r
if(B.a.I(r,16)===0&&h)b4.$1(r)
for(a0=k.b;g<o;){if(!(g>=0))return A.a(b0,g)
a1=b0[g]
a2=B.a.a5(a1*506832829>>>0,a0)
if(!(a2<e))return A.a(f,a2)
f[a2]=a1;++g}q=0}}else return!1}if(h)b4.$1(r)
if(f.d>=e&&i.a>=64&&o<n)return!1
a9.e=o
return!0},
ie(){var s,r,q,p,o,n
if(this.r>0)return!1
for(s=this.as,r=this.at,q=r.length,p=0;p<s;++p){if(!(p<q))return A.a(r,p)
o=r[p].a
n=o.length
if(1>=n)return A.a(o,1)
if(o[1].f>1)return!1
if(2>=n)return A.a(o,2)
if(o[2].f>1)return!1
if(3>=n)return A.a(o,3)
if(o[3].f>1)return!1}return!0},
hP(a){var s,r,q,p,o,n,m,l,k,j,i=this,h=i.f,g=a-h
if(g<=0)return
s=i.c
r=s.a
if(typeof r!=="number")return r.ap()
i.dv(g,r*h)
q=s.a
p=q*g
o=q*i.f
s=i.ch
s.toString
h=i.cx
h.toString
n=A.l(s,!1,null,h)
for(h=i.cy,s=n.a,r=n.d,m=s.length,l=0;l<p;++l){h.toString
k=o+l
j=r+l
if(!(j>=0&&j<m))return A.a(s,j)
j=B.a.i(s[j],8)
if(!(k>=0&&k<h.length))return A.a(h,k)
h[k]=j&255}i.f=a},
ho(a1,a2,a3){var s,r,q,p,o,n,m,l,k,j,i=this,h="_pixels8",g=i.e,f=B.a.V(g,a1),e=B.a.I(g,a1),d=i.dR(e,f),c=i.e,b=a1*a2,a=a1*a3,a0=i.x
g=i.b
while(!0){s=g.b
if(!(!(s.d>=s.c&&g.a>=64)&&c<a))break
if((e&a0)>>>0===0){r=i.bx(i.Q,i.z,i.y,e,f)
s=i.at
if(!(r<s.length))return A.a(s,r)
d=s[r]}if(g.a>=32)g.b6()
s=d.a
q=s.length
if(0>=q)return A.a(s,0)
p=s[0].b0(g)
if(p<256){s=i.CW
s===$&&A.c(h)
if(!(c>=0&&c<s.length))return A.a(s,c)
s[c]=p;++c;++e
if(e>=a1){++f
if(B.a.I(f,16)===0)i.cI(f)
e=0}}else if(p<280){o=i.c7(p-256)
if(4>=q)return A.a(s,4)
n=s[4].b0(g)
if(g.a>=32)g.b6()
m=i.eb(a1,i.c7(n))
if(c>=m&&b-c>=o)for(s=i.CW,l=0;l<o;++l){s===$&&A.c(h)
q=c+l
k=q-m
j=s.length
if(!(k>=0&&k<j))return A.a(s,k)
k=s[k]
if(!(q>=0&&q<j))return A.a(s,q)
s[q]=k}else{i.e=c
return!0}c+=o
e+=o
for(;e>=a1;){e-=a1;++f
if(B.a.I(f,16)===0)i.cI(f)}if(c<a&&(e&a0)>>>0!==0){r=i.bx(i.Q,i.z,i.y,e,f)
s=i.at
if(!(r<s.length))return A.a(s,r)
d=s[r]}}else return!1}i.cI(f)
i.e=c
return!0},
cI(a){var s,r,q,p=this,o=p.f,n=a-o,m=p.CW
m===$&&A.c("_pixels8")
s=p.c.a
if(typeof s!=="number")return s.ap()
r=A.l(m,!1,null,s*o)
if(n>0){m=p.cy
m.toString
s=p.db
s.toString
q=A.l(m,!1,null,s*o)
s=p.ax
if(0>=s.length)return A.a(s,0)
s[0].jv(o,o+n,r,q)}p.f=a},
iH(a){var s,r,q,p,o,n,m,l,k,j,i=this,h=i.c,g=h.a,f=i.f
if(typeof g!=="number")return g.ap()
s=a-f
if(s<=0)return
i.dv(s,g*f)
g=i.cx
g.toString
r=i.f
q=g
p=0
for(;p<s;++p,++r){o=0
while(!0){g=h.a
if(typeof g!=="number")return A.D(g)
if(!(o<g))break
g=i.ch
if(!(q>=0&&q<g.length))return A.a(g,q)
n=g[q]
g=i.d
g.toString
f=B.c.m(B.a.p(n>>>24&255,0,255))
m=B.c.m(B.a.p(n&255,0,255))
l=B.c.m(B.a.p(n>>>8&255,0,255))
k=B.c.m(B.a.p(n>>>16&255,0,255))
j=g.x
g=r*g.a+o
if(!(g>=0&&g<j.length))return A.a(j,g)
j[g]=(f<<24|m<<16|l<<8|k)>>>0;++o;++q}}i.f=a},
dv(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=this,e=f.ax,d=e.length,c=f.c.a
if(typeof c!=="number")return c.ap()
s=f.f
r=s+a
q=f.cx
q.toString
p=f.ch
p.toString
B.n.U(p,q,q+c*a,p,b)
for(c=r-s,p=c-1,o=b;n=d-1,d>0;o=q,d=n){if(!(n>=0&&n<e.length))return A.a(e,n)
m=e[n]
l=f.ch
l.toString
k=m.b
switch(m.a){case 2:m.jo(l,q,q+c*k)
break
case 0:m.kg(s,r,l,q)
if(r!==m.c){j=q-k
B.n.U(l,j,j+k,l,q+p*k)}break
case 1:m.jz(s,r,l,q)
break
case 3:if(o===q&&m.e>0){i=m.e
h=c*B.a.i(k+B.a.B(1,i)-1,i)
g=q+c*k-h
B.n.U(l,g,g+h,l,q)
m.eC(s,r,l,g,l,q)}else m.eC(s,r,l,o,l,q)
break}}},
iX(a,b,c,d){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=this
if(d&&e.b.N(1)!==0){s=e.b.N(3)+2
r=A.bK(a,s)
q=A.bK(b,s)
p=r*q
o=e.bw(r,q,!1)
e.y=s
for(n=1,m=0;m<p;++m){if(!(m<o.length))return A.a(o,m)
l=o[m]>>>8&65535
o[m]=l
if(l>=n)n=l+1}}else{o=null
n=1}k=J.ah(n,t.co)
for(j=0;j<n;++j)k[j]=A.nw()
for(i=c>0,m=0;m<n;++m)for(h=0;h<5;++h){g=B.fp[h]
if(h===0&&i)g+=B.a.B(1,c)
if(!(m<n))return A.a(k,m)
f=k[m].a
if(!(h<f.length))return A.a(f,h)
if(!e.iV(g,f[h]))return!1}e.Q=o
e.as=n
e.si4(k)
return!0},
iV(a,b){var s,r,q,p,o,n,m,l,k,j,i=this.b
if(i.N(1)!==0){s=t.t
r=A.b([0,0],s)
q=A.b([0,0],s)
p=A.b([0,0],s)
o=i.N(1)+1
B.b.h(r,0,i.N(i.N(1)===0?1:8))
B.b.h(q,0,0)
s=o-1
B.b.h(p,0,s)
if(o===2){B.b.h(r,1,i.N(8))
B.b.h(q,1,1)
B.b.h(p,1,s)}n=b.ju(p,q,r,a,o)}else{m=new Int32Array(19)
l=i.N(4)+4
if(l>19)return!1
p=new Int32Array(a)
for(k=0;k<l;++k){s=B.eW[k]
j=i.N(3)
if(!(s<19))return A.a(m,s)
m[s]=j}n=this.iW(m,a,p)
if(n)n=b.eB(p,a)}return n},
iW(a,b,c){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=t.L
e.a(a)
e.a(c)
s=A.l2()
if(!s.eB(a,19))return!1
e=this.b
if(e.N(1)!==0){r=2+e.N(2+2*e.N(3))
if(r>b)return!1}else r=b
for(q=c.length,p=0,o=8;p<b;r=n){n=r-1
if(r===0)break
if(e.a>=32)e.b6()
m=s.b0(e)
if(m<16){l=p+1
if(!(p>=0&&p<q))return A.a(c,p)
c[p]=m
if(m!==0)o=m
p=l}else{k=m-16
if(!(k<3))return A.a(B.aa,k)
j=B.aa[k]
i=B.bx[k]
h=e.N(j)+i
if(p+h>b)return!1
else{g=m===16?o:0
for(;f=h-1,h>0;h=f,p=l){l=p+1
if(!(p>=0&&p<q))return A.a(c,p)
c[p]=g}}}}return!0},
c7(a){var s
if(a<4)return a+1
s=B.a.i(a-2,1)
return B.a.B(2+(a&1),s)+this.b.N(s)+1},
eb(a,b){var s,r,q
if(b>120)return b-120
else{s=b-1
if(!(s>=0))return A.a(B.ag,s)
r=B.ag[s]
q=(r>>>4)*a+(8-(r&15))
return q>=1?q:1}},
hO(a,b){var s,r,q,p,o,n=B.a.B(1,B.a.L(8,b.e)),m=new Uint32Array(n),l=A.z(b.d.buffer,0,null),k=A.z(m.buffer,0,null),j=b.d
if(0>=j.length)return A.a(j,0)
j=j[0]
if(0>=n)return A.a(m,0)
m[0]=j
s=4*a
for(j=l.length,r=k.length,q=4;q<s;++q){if(!(q<j))return A.a(l,q)
p=l[q]
o=q-4
if(!(o<r))return A.a(k,o)
o=k[o]
if(!(q<r))return A.a(k,q)
k[q]=p+o&255}for(s=4*n;q<s;++q){if(!(q<r))return A.a(k,q)
k[q]=0}b.d=m
return!0},
bx(a,b,c,d,e){var s
if(c===0)return 0
a.toString
s=b*B.a.i(e,c)+B.a.i(d,c)
if(!(s<a.length))return A.a(a,s)
return a[s]},
dR(a,b){var s=this,r=s.bx(s.Q,s.z,s.y,a,b),q=s.at
if(!(r<q.length))return A.a(q,r)
return q[r]},
si4(a){this.at=t.kk.a(a)}}
A.eo.prototype={
jT(a){return this.hP(a)}}
A.fe.prototype={
eR(){var s,r,q,p=this.a
if(p<32){s=this.c
r=B.a.a5(s[0],p)
s=s[1]
if(!(p>=0))return A.a(B.v,p)
q=r+((s&B.v[p])>>>0)*(B.v[32-p]+1)}else{s=this.c
q=p===32?s[1]:B.a.a5(s[1],p-32)}return q},
N(a){var s,r=this,q=r.b
if(!(q.d>=q.c&&r.a>=64)&&a<25){q=r.eR()
if(!(a<33))return A.a(B.v,a)
s=B.v[a]
r.a+=a
r.b6()
return(q&s)>>>0}else throw A.d(A.f("Not enough data in input."))},
b6(){var s,r,q,p,o=this,n=o.b,m=o.c,l=n.c
while(!0){s=o.a
if(!(s>=8&&n.d<l))break
r=n.a
q=n.d++
if(!(q>=0&&q<r.length))return A.a(r,q)
q=r[q]
r=m[0]
p=m[1]
m[0]=(r>>>8)+(p&255)*16777216
m[1]=p>>>8
m[1]=(m[1]|q*16777216)>>>0
o.a=s-8}}}
A.ik.prototype={}
A.ff.prototype={
jv(a,b,c,d){var s,r,q,p,o,n,m=this.e,l=B.a.L(8,m),k=this.b,j=this.d
if(l<8){s=B.a.B(1,m)-1
r=B.a.B(1,l)-1
for(q=a;q<b;++q)for(p=0,o=0;o<k;++o){if((o&s)>>>0===0){m=c.a
n=c.d
if(!(n>=0&&n<m.length))return A.a(m,n)
p=m[n]
c.d=n+1}m=(p&r)>>>0
if(!(m>=0&&m<j.length))return A.a(j,m)
m=j[m]
J.n(d.a,d.d,m>>>8&255);++d.d
p=B.a.i(p,l)}}else for(q=a;q<b;++q)for(o=0;o<k;++o){m=c.a
n=c.d
if(!(n>=0&&n<m.length))return A.a(m,n)
m=m[n]
c.d=n+1
if(m>>>0!==m||m>=j.length)return A.a(j,m)
m=j[m]
J.n(d.a,d.d,m>>>8&255);++d.d}},
eC(a,b,c,d,e,f){var s,r,q,p,o,n,m,l,k,j=this.e,i=B.a.L(8,j),h=this.b,g=this.d
if(i<8){s=B.a.B(1,j)-1
r=B.a.B(1,i)-1
for(j=e.length,q=c.length,p=a;p<b;++p)for(o=0,n=0;n<h;++n,f=l){if((n&s)>>>0===0){m=d+1
if(!(d>=0&&d<q))return A.a(c,d)
o=c[d]>>>8&255
d=m}l=f+1
k=o&r
if(!(k>=0&&k<g.length))return A.a(g,k)
k=g[k]
if(!(f>=0&&f<j))return A.a(e,f)
e[f]=k
o=B.a.L(o,i)}}else for(j=c.length,q=e.length,p=a;p<b;++p)for(n=0;n<h;++n,f=l,d=m){l=f+1
g.toString
m=d+1
if(!(d>=0&&d<j))return A.a(c,d)
k=c[d]>>>8&255
if(!(k<g.length))return A.a(g,k)
k=g[k]
if(!(f>=0&&f<q))return A.a(e,f)
e[f]=k}},
jz(a5,a6,a7,a8){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=this.b,a1=this.e,a2=B.a.B(1,a1)-1,a3=A.bK(a0,a1),a4=B.a.i(a5,a1)*a3
for(a1=a7.length,s=a5;s<a6;){r=new Uint8Array(3)
for(q=a4,p=0;p<a0;++p){if((p&a2)>>>0===0){o=this.d
n=q+1
if(!(q<o.length))return A.a(o,q)
o=o[q]
r[0]=o&255
r[1]=o>>>8&255
r[2]=o>>>16&255
q=n}o=a8+p
if(!(o>=0&&o<a1))return A.a(a7,o)
m=a7[o]
l=m>>>8&255
k=r[0]
j=$.a1()
j[0]=k
k=$.a7()
i=k.length
if(0>=i)return A.a(k,0)
h=k[0]
j[0]=l
if(0>=i)return A.a(k,0)
g=k[0]
f=$.kF()
f[0]=h*g
e=$.mW()
d=e.length
if(0>=d)return A.a(e,0)
c=(m>>>16&255)+(e[0]>>>5)>>>0&255
j[0]=r[1]
if(0>=i)return A.a(k,0)
h=k[0]
j[0]=l
if(0>=i)return A.a(k,0)
f[0]=h*k[0]
if(0>=d)return A.a(e,0)
b=e[0]
j[0]=r[2]
if(0>=i)return A.a(k,0)
h=k[0]
j[0]=c
if(0>=i)return A.a(k,0)
f[0]=h*k[0]
if(0>=d)return A.a(e,0)
a=e[0]
a7[o]=(m&4278255360|c<<16|((m&255)+(b>>>5)>>>0)+(a>>>5)>>>0&255)>>>0}a8+=a0;++s
if((s&a2)>>>0===0)a4+=a3}},
kg(a,b,c,d){var s,r,q,p,o,n,m,l,k,j,i,h=this,g=h.b
if(a===0){s=d-1
r=c.length
if(!(s>=0&&s<r))return A.a(c,s)
A.il(c,d,4278190080)
for(q=1;q<g;++q){s=d+q
p=s-1
if(!(p>=0&&p<r))return A.a(c,p)
A.il(c,s,c[p])}d+=g;++a}s=h.e
o=B.a.B(1,s)-1
n=A.bK(g,s)
m=B.a.i(a,s)*n
for(s=c.length,l=a;l<b;){r=d-1
if(!(r>=0&&r<s))return A.a(c,r)
r=d-g
if(!(r>=0&&r<s))return A.a(c,r)
A.il(c,d,c[r])
r=h.d
k=m+1
if(!(m<r.length))return A.a(r,m)
j=$.lM[r[m]>>>8&15]
for(q=1;q<g;++q){if((q&o)>>>0===0){r=h.d
i=k+1
if(!(k<r.length))return A.a(r,k)
j=$.lM[r[k]>>>8&15]
k=i}r=d+q
p=r-1
if(!(p>=0&&p<s))return A.a(c,p)
A.il(c,r,j.$3(c,c[p],r-g))}d+=g;++l
if((l&o)>>>0===0)m+=n}},
jo(a,b,c){var s,r,q,p
for(s=a.length;b<c;b=p){if(!(b>=0&&b<s))return A.a(a,b)
r=a[b]
q=r>>>8&255
p=b+1
a[b]=(r&4278255360|(r&16711935)+(q<<16|q)&16711935)>>>0}}}
A.is.prototype={
geO(){var s=this,r=s.d
if(r>1||s.e>=4||s.f>1||s.r!==0)return!1
return!0},
jG(a,b,c){var s,r,q,p,o,n,m,l=this
if(!l.geO())return!1
s=l.e
if(!(s<4))return A.a(B.am,s)
r=B.am[s]
if(l.d===0){s=l.b
q=a*s
p=l.a
B.e.U(c,q,b*s,p.a,p.d-p.b+q)}else{s=a+b
p=l.x
p===$&&A.c("_vp8l")
p.cy=c
o=p.c
if(l.y){n=o.a
o=o.b
s=p.ho(A.o(n),A.o(o),s)}else{n=p.ch
n.toString
m=o.a
o=o.b
p=p.cE(n,A.o(m),A.o(o),s,t.lt.a(p.gjS()))
s=p}if(!s)return!1}if(r!=null){s=l.b
r.$6(s,l.c,s,a,b,c)}if(l.f===1)if(!l.hH(c,l.b,l.c,a,b))return!1
if(a+b===l.c)l.w=!0
return!0},
hH(a,b,c,d,e){if(b<=0||c<=0||d<0||e<0||d+e>c)return!1
return!0}}
A.di.prototype={
fI(a,b){a.t()
this.r=0
this.w=a.d-a.b
this.x=b-16}}
A.ep.prototype={}
A.ea.prototype={
cP(a){var s,r,q=this
if(a===0)return!1
s=(a<<1>>>0)-1
q.e=s
s=s<<1>>>0
r=q.d=new Int32Array(s)
if(1>=s)return A.a(r,1)
r[1]=-1
q.f=1
B.e.ak(q.a,0,128,255)
return!0},
eB(a,b){var s,r,q,p,o,n,m=this
t.L.a(a)
for(s=a.length,r=0,q=0,p=0;p<b;++p){if(!(p<s))return A.a(a,p)
if(a[p]>0){++r
q=p}}if(!m.cP(r))return!1
if(r===1){if(q<0||q>=b)return!1
return m.ct(q,0,0)}o=new Int32Array(b)
if(!m.i5(a,b,o))return!1
for(p=0;p<b;++p){if(!(p<s))return A.a(a,p)
n=a[p]
if(n>0)if(!m.ct(p,o[p],n))return!1}return m.f===m.e},
ju(a,b,c,d,e){var s,r,q=this,p=t.L
p.a(a)
p.a(b)
p.a(c)
if(!q.cP(e))return!1
for(s=0;s<e;++s){if(!(s<2))return A.a(b,s)
p=b[s]
if(p!==-1){r=c[s]
if(r>=d)return q.f===q.e
if(!q.ct(r,p,a[s]))return q.f===q.e}}return q.f===q.e},
b0(a){var s,r,q,p=this,o=a.eR(),n=a.a,m=o&127,l=p.a[m]
if(l<=7){a.a=n+l
return p.b[m]}s=p.c[m]
n+=7
o=o>>>7
do{r=p.d
r===$&&A.c("tree")
q=(s<<1>>>0)+1
if(!(q<r.length))return A.a(r,q)
s=s+r[q]+(o&1)
o=o>>>1;++n}while(p.e8(s))
a.a=n
r=p.d
q=s<<1>>>0
if(!(q<r.length))return A.a(r,q)
return r[q]},
ct(a,b,c){var s,r,q,p,o,n,m,l,k,j,i,h,g=this
if(c<=7){s=g.eh(b,c)
for(r=B.a.D(1,7-c),q=g.b,p=g.a,o=0;o<r;++o){n=(s|B.a.D(o,c))>>>0
if(!(n<128))return A.a(q,n)
q[n]=a
p[n]=c}}else s=g.eh(B.a.a8(b,c-7),7)
for(r=g.c,m=7,l=0;k=c-1,c>0;c=k){q=g.e
if(l>=q)return!1
p=g.d
p===$&&A.c("tree")
j=(l<<1>>>0)+1
i=p.length
if(!(j<i))return A.a(p,j)
h=p[j]
if(h<0){h=g.f
if(h===q)return!1
p[j]=h-l
g.f=h+2
q=(h<<1>>>0)+1
if(!(q<i))return A.a(p,q)
p[q]=-1
h=(h+1<<1>>>0)+1
if(!(h<i))return A.a(p,h)
p[h]=-1}else if(h===0)return!1
l+=p[j]+(B.a.a8(b,k)&1);--m
if(m===0){if(!(s<128))return A.a(r,s)
r[s]=l}}if(g.il(l))g.im(l,0)
else if(g.e8(l))return!1
r=g.d
r===$&&A.c("tree")
q=l<<1>>>0
if(!(q<r.length))return A.a(r,q)
r[q]=a
return!0},
eh(a,b){var s=B.X[a&15],r=B.a.i(a,4)
if(!(r<16))return A.a(B.X,r)
return B.a.a5((s<<4|B.X[r])>>>0,8-b)},
im(a,b){var s,r=this.d
r===$&&A.c("tree")
s=(a<<1>>>0)+1
if(!(s<r.length))return A.a(r,s)
r[s]=b},
e8(a){var s,r=this.d
r===$&&A.c("tree")
s=(a<<1>>>0)+1
if(!(s<r.length))return A.a(r,s)
return r[s]!==0},
il(a){var s,r=this.d
r===$&&A.c("tree")
s=(a<<1>>>0)+1
if(!(s<r.length))return A.a(r,s)
return r[s]<0},
i5(a,b,c){var s,r,q,p,o,n,m,l,k,j,i=t.L
i.a(a)
i.a(c)
s=new Int32Array(16)
r=new Int32Array(16)
for(i=a.length,q=0,p=0;q<b;++q){if(!(q<i))return A.a(a,q)
o=a[q]
if(o>p)p=o}if(p>15)return!1
for(q=0;q<b;++q){if(!(q<i))return A.a(a,q)
n=a[q]
if(!(n>=0&&n<16))return A.a(s,n)
m=s[n]
if(!(n<16))return A.a(s,n)
s[n]=m+1}if(0>=16)return A.a(s,0)
s[0]=0
if(0>=16)return A.a(r,0)
r[0]=-1
for(l=1,k=0;l<=p;++l){k=k+s[l-1]<<1>>>0
if(!(l<16))return A.a(r,l)
r[l]=k}for(n=c.length,q=0;q<b;++q){if(!(q<i))return A.a(a,q)
m=a[q]
if(m>0){if(!(m<16))return A.a(r,m)
j=r[m]
if(!(m<16))return A.a(r,m)
r[m]=j+1
if(!(q<n))return A.a(c,q)
c[q]=j}else{if(!(q<n))return A.a(c,q)
c[q]=-1}}return!0}}
A.c0.prototype={}
A.dj.prototype={}
A.cK.prototype={}
A.dh.prototype={
bm(a){var s=A.l(t.L.a(a),!1,null,0)
this.b=s
if(!this.dQ(s))return!1
return!0},
aH(a){var s,r=this,q=null,p=A.l(t.L.a(a),!1,q,0)
r.b=p
if(!r.dQ(p))return q
p=new A.cK(A.b([],t.J))
r.a=p
s=r.b
s.toString
if(!r.eu(s,p))return q
p=r.a
switch(p.f){case 3:p.as=p.z.length
return p
case 2:s=r.b
s.toString
s.d=p.ay
if(!A.kh(s,p).bH())return q
p=r.a
p.as=p.z.length
return p
case 1:s=r.b
s.toString
s.d=p.ay
if(!A.kf(s,p).bH())return q
p=r.a
p.as=p.z.length
return p}return q},
a4(a){var s,r,q,p,o=this,n=o.b
if(n==null||o.a==null)return null
s=o.a
if(s.e){s=s.z
r=s.length
if(a>=r||!1)return null
if(!(a<r))return A.a(s,a)
q=s[a]
n.toString
s=q.x
s===$&&A.c("_frameSize")
r=q.w
r===$&&A.c("_framePosition")
return o.dJ(n.b2(s,r),a)}r=s.f
if(r===2){n.toString
p=n.b2(s.ch,s.ay)
n=o.a
n.toString
return A.kh(p,n).aK()}else if(r===1){n.toString
p=n.b2(s.ch,s.ay)
n=o.a
n.toString
return A.kf(p,n).aK()}return null},
a6(a){var s
this.aH(t.L.a(a))
s=this.a
s.Q=0
s.as=1
return this.a4(0)},
dJ(a,b){var s,r,q,p=null,o=A.b([],t.J),n=new A.cK(o)
if(!this.eu(a,n))return p
if(n.f===0)return p
s=this.a
n.Q=s.Q
n.as=s.as
if(n.e){s=o.length
if(b>=s||!1)return p
if(!(b<s))return A.a(o,b)
r=o[b]
o=r.x
o===$&&A.c("_frameSize")
s=r.w
s===$&&A.c("_framePosition")
return this.dJ(a.b2(o,s),b)}else{q=a.b2(n.ch,n.ay)
o=n.f
if(o===2)return A.kh(q,n).aK()
else if(o===1)return A.kf(q,n).aK()}return p},
dQ(a){if(a.O(4)!=="RIFF")return!1
a.j()
if(a.O(4)!=="WEBP")return!1
return!0},
eu(a,b){var s,r,q,p,o,n,m,l,k,j,i,h=a.b,g=a.c,f=!1
while(!0){if(!(a.d<g&&!f))break
s=a.O(4)
r=a.j()
q=r+1>>>1<<1>>>0
p=a.d
o=p-h
switch(s){case"VP8X":if(!this.i3(a,b))return!1
break
case"VP8 ":b.ay=o
b.ch=r
b.f=1
f=!0
break
case"VP8L":b.ay=o
b.ch=r
b.f=2
f=!0
break
case"ALPH":n=a.a
m=a.e
l=n.length
n=new A.a3(n,0,l,0,m)
b.at=n
n.d=p
a.d+=q
break
case"ANIM":b.f=3
k=a.j()
a.k()
B.c.m(B.a.p(k&255,0,255))
B.c.m(B.a.p(k>>>24&255,0,255))
B.c.m(B.a.p(k>>>16&255,0,255))
B.c.m(B.a.p(k>>>8&255,0,255))
break
case"ANMF":if(!this.hZ(a,b,r))return!1
break
case"ICCP":b.toString
j=a.R(r)
a.d=a.d+(j.c-j.d)
j.S()
break
case"EXIF":b.toString
a.O(r)
break
case"XMP ":b.toString
a.O(r)
break
default:A.mw("UNKNOWN WEBP TAG: "+s)
a.d+=q
break}p=a.d
i=q-(p-h-o)
if(i>0)a.d=p+i}if(!b.d)b.d=b.at!=null
return b.f!==0},
i3(a,b){var s,r,q,p,o=a.t()
if((o&192)!==0)return!1
s=B.a.i(o,4)
r=B.a.i(o,1)
if((o&1)!==0)return!1
if(a.an()!==0)return!1
q=a.an()
p=a.an()
b.a=q+1
b.b=p+1
b.e=(r&1)!==0
b.d=(s&1)!==0
return!0},
hZ(a,b,c){var s
a.an()
a.an()
a.an()
a.an()
a.an()
s=new A.ep()
s.fI(a,c)
if(s.r!==0)return!1
B.b.A(b.z,s)
return!0}}
A.e9.prototype={
fz(a,b,c){var s,r,q,p,o,n,m,l=this,k=a.a,j=a.b
l.bF(A.h9("R",k,j,c,b))
l.bF(A.h9("G",k,j,c,b))
l.bF(A.h9("B",k,j,c,b))
if(a.c===B.f)l.bF(A.h9("A",k,j,c,b))
s=a.aw()
for(r=s.length,q=0,p=0;q<j;++q)for(o=0;o<k;++o){n=l.b
n.toString
m=p+1
if(!(p>=0&&p<r))return A.a(s,p)
n.aS(o,q,s[p]/255)
n=l.c
n.toString
p=m+1
if(!(m>=0&&m<r))return A.a(s,m)
n.aS(o,q,s[m]/255)
n=l.d
n.toString
m=p+1
if(!(p>=0&&p<r))return A.a(s,p)
n.aS(o,q,s[p]/255)
n=l.e
if(n!=null){p=m+1
if(!(m>=0&&m<r))return A.a(s,m)
n.aS(o,q,s[m]/255)}else p=m}},
gkI(a){var s=this.a
if(s.a===0)s=0
else{s=s.gaG()
s=s.b.$1(J.dP(s.a)).b}return s},
gb9(a){var s=this.a
if(s.a===0)s=0
else{s=s.gaG()
s=s.b.$1(J.dP(s.a)).c}return s},
b1(a,b,c){var s=this.b
if(s!=null)if(s.d===3)s.aS(a,b,c)
else s.bX(a,b,A.o(c))},
bt(a,b,c){var s=this.c
if(s!=null)if(this.b.d===3)s.aS(a,b,c)
else s.bX(a,b,A.o(c))},
bW(a,b,c){var s
if(this.c!=null){s=this.d
if(s.d===3)s.aS(a,b,c)
else s.bX(a,b,A.o(c))}},
de(a,b,c){var s=this.e
if(s!=null)if(s.d===3)s.aS(a,b,c)
else s.bX(a,b,A.o(c))},
bF(a){var s=this,r=a.a
s.a.h(0,r,a)
switch(r){case"R":s.b=a
break
case"G":s.c=a
break
case"B":s.d=a
break
case"A":s.e=a
break
case"Z":break}}}
A.cF.prototype={
bV(a,b){var s,r,q,p=this,o=b*p.b+a,n=p.d,m=n===1
if(m||n===0){n=p.f
if(!(o>=0&&o<n.length))return A.a(n,o)
n=A.o(n[o])
s=p.e
if(s===8)r=255
else r=s===16?65535:4294967295
return n/(m?r-1:r)}n=n===3&&p.e===16
m=p.f
s=m.length
if(n){if(!(o>=0&&o<s))return A.a(m,o)
n=A.o(m[o])
if($.O==null)A.aP()
m=$.O
if(!(n>=0&&n<m.length))return A.a(m,n)
q=m[n]}else{if(!(o>=0&&o<s))return A.a(m,o)
q=m[o]}return q},
aS(a,b,c){var s,r,q,p=this
if(p.d!==3)return
s=b*p.b+a
r=p.f
q=J.R(r)
if(p.e===16)q.h(r,s,A.nx(c))
else q.h(r,s,c)},
bX(a,b,c){J.n(this.f,b*this.b+a,c)}}
A.jE.prototype={
$2(a,b){return Math.log(a*b+1)/b},
$S:14}
A.jD.prototype={
$2(a,b){var s,r=Math.max(0,a*b)
if(r>1){s=this.a.$2(r-1,0.184874)
if(typeof s!=="number")return A.D(s)
r=1+s}return Math.pow(r,0.4545)*84.66},
$S:14}
A.hb.prototype={
u(a){return"ICCPCompression."+this.b}}
A.hc.prototype={
jB(){var s,r=this
if(r.b===B.P)return r.c
s=t.D.a(B.a6.jO(r.c))
r.c=s
r.b=B.P
return s}}
A.h3.prototype={
u(a){return"Format."+this.b}}
A.dU.prototype={
u(a){return"Channels."+this.b}}
A.fS.prototype={
u(a){return"BlendMode."+this.b}}
A.fZ.prototype={
u(a){return"DisposeMode."+this.b}}
A.c3.prototype={
aw(){var s=A.z(this.x.buffer,0,null)
switch(2){case 2:return s}},
gv(a){return this.x.length},
jt(a,b){return a>=0&&a<this.a&&b>=0&&b<this.b},
Y(a,b){var s,r
if(this.jt(a,b)){s=this.x
r=b*this.a+a
if(!(r>=0&&r<s.length))return A.a(s,r)
r=s[r]
s=r}else s=0
return s},
f6(a,b,c){if(c===B.b3)return this.f5(a,b)
else if(c===B.b2)return this.f7(a,b)
return this.Y(B.c.m(a),B.c.m(b))},
f7(a,b){var s,r,q,p,o,n,m,l,k=this,j=B.c.m(a),i=j-(a>=0?0:1),h=i+1
j=B.c.m(b)
s=j-(b>=0?0:1)
r=s+1
j=new A.hm(a-i,b-s)
q=k.Y(i,s)
p=r>=k.b
o=p?q:k.Y(i,r)
n=h>=k.a
m=n?q:k.Y(h,s)
l=n||p?q:k.Y(h,r)
return A.aE(j.$4(q&255,m&255,o&255,l&255),j.$4(q>>>8&255,m>>>8&255,o>>>8&255,l>>>8&255),j.$4(q>>>16&255,m>>>16&255,o>>>16&255,l>>>16&255),j.$4(q>>>24&255,m>>>24&255,o>>>24&255,l>>>24&255))},
f5(d5,d6){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9=this,d0=B.c.m(d5),d1=d0-(d5>=0?0:1),d2=d1-1,d3=d1+1,d4=d1+2
d0=B.c.m(d6)
s=d0-(d6>=0?0:1)
r=s-1
q=s+1
p=s+2
o=d5-d1
n=d6-s
d0=new A.hl()
m=c9.Y(d1,s)
l=d2<0
k=!l
j=!k||r<0?m:c9.Y(d2,r)
i=l?m:c9.Y(d1,r)
h=r<0
g=h||d3>=c9.a?m:c9.Y(d3,r)
f=c9.a
e=d4>=f
d=!e
c=!d||h?m:c9.Y(d4,r)
b=d0.$5(o,j&255,i&255,g&255,c&255)
a=d0.$5(o,j>>>8&255,i>>>8&255,g>>>8&255,c>>>8&255)
a0=d0.$5(o,j>>>16&255,i>>>16&255,g>>>16&255,c>>>16&255)
a1=d0.$5(o,j>>>24&255,i>>>24&255,g>>>24&255,c>>>24&255)
a2=l?m:c9.Y(d2,s)
l=d3>=f
a3=l?m:c9.Y(d3,s)
a4=e?m:c9.Y(d4,s)
a5=d0.$5(o,a2&255,m&255,a3&255,a4&255)
a6=d0.$5(o,a2>>>8&255,m>>>8&255,a3>>>8&255,a4>>>8&255)
a7=d0.$5(o,a2>>>16&255,m>>>16&255,a3>>>16&255,a4>>>16&255)
a8=d0.$5(o,a2>>>24&255,m>>>24&255,a3>>>24&255,a4>>>24&255)
a9=!k||q>=c9.b?m:c9.Y(d2,q)
h=c9.b
f=q>=h
b0=f?m:c9.Y(d1,q)
l=!l
b1=!l||f?m:c9.Y(d3,q)
b2=!d||f?m:c9.Y(d4,q)
b3=d0.$5(o,a9&255,b0&255,b1&255,b2&255)
b4=d0.$5(o,a9>>>8&255,b0>>>8&255,b1>>>8&255,b2>>>8&255)
b5=d0.$5(o,a9>>>16&255,b0>>>16&255,b1>>>16&255,b2>>>16&255)
b6=d0.$5(o,a9>>>24&255,b0>>>24&255,b1>>>24&255,b2>>>24&255)
b7=!k||p>=h?m:c9.Y(d2,p)
k=p>=h
b8=k?m:c9.Y(d1,p)
b9=!l||k?m:c9.Y(d3,p)
c0=!d||k?m:c9.Y(d4,p)
c1=d0.$5(o,b7&255,b8&255,b9&255,c0&255)
c2=d0.$5(o,b7>>>8&255,b8>>>8&255,b9>>>8&255,c0>>>8&255)
c3=d0.$5(o,b7>>>16&255,b8>>>16&255,b9>>>16&255,c0>>>16&255)
c4=d0.$5(o,b7>>>24&255,b8>>>24&255,b9>>>24&255,c0>>>24&255)
c5=d0.$5(n,b,a5,b3,c1)
c6=d0.$5(n,a,a6,b4,c2)
c7=d0.$5(n,a0,a7,b5,c3)
c8=d0.$5(n,a1,a8,b6,c4)
return A.aE(B.c.m(c5),B.c.m(c6),B.c.m(c7),B.c.m(c8))},
fb(a,b,c){var s=this.x,r=b*this.a+a
if(!(r>=0&&r<s.length))return A.a(s,r)
s[r]=c},
jr(a){var s,r,q,p
t.je.a(a)
if(this.Q==null){s=t.N
this.seW(A.J(s,s))}for(s=A.cQ(a,a.r,A.w(a).c);s.C();){r=s.d
q=this.Q
q.toString
p=a.q(0,r)
p.toString
q.h(0,r,p)}},
seW(a){this.Q=t.lG.a(a)}}
A.hm.prototype={
$4(a,b,c,d){var s=this.b
return B.c.m(a+this.a*(b-a+s*(a+d-c-b))+s*(c-a))},
$S:34}
A.hl.prototype={
$5(a,b,c,d,e){var s=-b,r=a*a
return c+0.5*(a*(s+d)+r*(2*b-5*c+4*d-e)+r*a*(s+3*c-3*d+e))},
$S:35}
A.hg.prototype={
u(a){return"ImageException: "+this.a}}
A.e0.prototype={
u(a){return"DitherKernel."+this.b}}
A.a3.prototype={
gv(a){return this.c-this.d},
h(a,b,c){J.n(this.a,this.d+b,c)
return c},
am(a,b,c,d){var s=this.a,r=J.R(s),q=this.d+a
if(c instanceof A.a3)r.U(s,q,q+b,c.a,c.d+d)
else r.U(s,q,q+b,t.L.a(c),d)},
b_(a,b,c){return this.am(a,b,c,0)},
ka(a,b,c){var s=this.a,r=this.d+a
J.aJ(s,r,r+b,c)},
cr(a,b,c){var s=this,r=c!=null?s.b+c:s.d
return A.l(s.a,s.e,a,r+b)},
R(a){return this.cr(a,0,null)},
b2(a,b){return this.cr(a,0,b)},
bd(a,b){return this.cr(a,b,null)},
t(){var s=this.a,r=this.d++
if(!(r>=0&&r<s.length))return A.a(s,r)
return s[r]},
a_(a){var s=this.R(a)
this.d=this.d+(s.c-s.d)
return s},
O(a){var s,r,q,p,o=this
if(a==null){s=A.b([],t.t)
for(r=o.c;q=o.d,q<r;){p=o.a
o.d=q+1
if(!(q>=0&&q<p.length))return A.a(p,q)
q=p[q]
if(q===0)return A.i_(s,0,null)
B.b.A(s,q)}throw A.d(A.f(u.c))}return A.i_(o.a_(a).S(),0,null)},
bO(){return this.O(null)},
kp(){var s,r,q,p=this,o=A.b([],t.t)
for(s=p.c;r=p.d,r<s;){q=p.a
p.d=r+1
if(!(r>=0&&r<q.length))return A.a(q,r)
r=q[r]
if(r===0){t.L.a(o)
return B.hX.aY(o)}B.b.A(o,r)}throw A.d(A.f(u.c))},
k(){var s,r,q=this,p=q.a,o=q.d,n=q.d=o+1,m=p.length
if(!(o>=0&&o<m))return A.a(p,o)
o=p[o]
if(typeof o!=="number")return o.a0()
s=o&255
q.d=n+1
if(!(n>=0&&n<m))return A.a(p,n)
n=p[n]
if(typeof n!=="number")return n.a0()
r=n&255
if(q.e)return s<<8|r
return r<<8|s},
an(){var s,r,q,p=this,o=p.a,n=p.d,m=p.d=n+1,l=o.length
if(!(n>=0&&n<l))return A.a(o,n)
n=o[n]
if(typeof n!=="number")return n.a0()
s=n&255
n=p.d=m+1
if(!(m>=0&&m<l))return A.a(o,m)
m=o[m]
if(typeof m!=="number")return m.a0()
r=m&255
p.d=n+1
if(!(n>=0&&n<l))return A.a(o,n)
n=o[n]
if(typeof n!=="number")return n.a0()
q=n&255
if(p.e)return q|r<<8|s<<16
return s|r<<8|q<<16},
j(){var s,r,q,p,o=this,n=o.a,m=o.d,l=o.d=m+1,k=n.length
if(!(m>=0&&m<k))return A.a(n,m)
m=n[m]
if(typeof m!=="number")return m.a0()
s=m&255
m=o.d=l+1
if(!(l>=0&&l<k))return A.a(n,l)
l=n[l]
if(typeof l!=="number")return l.a0()
r=l&255
l=o.d=m+1
if(!(m>=0&&m<k))return A.a(n,m)
m=n[m]
if(typeof m!=="number")return m.a0()
q=m&255
o.d=l+1
if(!(l>=0&&l<k))return A.a(n,l)
l=n[l]
if(typeof l!=="number")return l.a0()
p=l&255
if(o.e)return(s<<24|r<<16|q<<8|p)>>>0
return(p<<24|q<<16|r<<8|s)>>>0},
cp(){return A.qn(this.d7())},
d7(){var s,r,q,p,o,n,m,l,k=this,j=k.a,i=k.d,h=k.d=i+1,g=j.length
if(!(i>=0&&i<g))return A.a(j,i)
i=j[i]
if(typeof i!=="number")return i.a0()
s=i&255
i=k.d=h+1
if(!(h>=0&&h<g))return A.a(j,h)
h=j[h]
if(typeof h!=="number")return h.a0()
r=h&255
h=k.d=i+1
if(!(i>=0&&i<g))return A.a(j,i)
i=j[i]
if(typeof i!=="number")return i.a0()
q=i&255
i=k.d=h+1
if(!(h>=0&&h<g))return A.a(j,h)
h=j[h]
if(typeof h!=="number")return h.a0()
p=h&255
h=k.d=i+1
if(!(i>=0&&i<g))return A.a(j,i)
i=j[i]
if(typeof i!=="number")return i.a0()
o=i&255
i=k.d=h+1
if(!(h>=0&&h<g))return A.a(j,h)
h=j[h]
if(typeof h!=="number")return h.a0()
n=h&255
h=k.d=i+1
if(!(i>=0&&i<g))return A.a(j,i)
i=j[i]
if(typeof i!=="number")return i.a0()
m=i&255
k.d=h+1
if(!(h>=0&&h<g))return A.a(j,h)
h=j[h]
if(typeof h!=="number")return h.a0()
l=h&255
if(k.e)return(B.a.B(s,56)|B.a.B(r,48)|B.a.B(q,40)|B.a.B(p,32)|o<<24|n<<16|m<<8|l)>>>0
return(B.a.B(l,56)|B.a.B(m,48)|B.a.B(n,40)|B.a.B(o,32)|p<<24|q<<16|r<<8|s)>>>0},
bQ(a,b,c){var s,r=this,q=r.a
if(t.D.b(q))return r.f_(b,c)
s=r.b+b+b
return J.fI(q,s,c<=0?r.c:s+c)},
f_(a,b){var s,r=this,q=b==null?r.c-r.d-a:b,p=r.a
if(t.D.b(p))return A.z(p.buffer,p.byteOffset+r.d+a,q)
s=r.d+a
s=J.fI(p,s,s+q)
return new Uint8Array(A.b_(s))},
S(){return this.f_(0,null)},
bR(){var s=this.a
if(t.D.b(s))return A.k4(s.buffer,s.byteOffset+this.d,null)
return A.k4(this.S().buffer,0,null)},
sd0(a,b){this.a=t.L.a(b)}}
A.cL.prototype={
u(a){return"Interpolation."+this.b}}
A.hF.prototype={
f4(a){var s,r,q,p,o=a.a*a.b,n=new Uint8Array(o)
for(s=a.x,r=s.length,q=0;q<r;++q){p=s[q]
p=this.e0(p>>>16&255,p>>>8&255,p&255)
if(!(q<o))return A.a(n,q)
n[q]=p}return n},
ia(a){var s,r,q,p,o,n,m,l,k=this
k.skc(Math.max(a,4))
s=k.c
k.f=s-k.d
k.r=s-1
r=B.a.F(s,8)
k.w=r
k.x=r*256
k.Q=new Int32Array(s*4)
r=s*3
k.a=new Uint8Array(r)
k.d=3
k.e=2
s=B.a.i(s,3)
k.y=new Int32Array(s)
s=t.dx
q=t.H
k.sfU(q.a(A.H(r,0,!1,s)))
k.sfS(q.a(A.H(k.c,0,!1,s)))
k.sfT(q.a(A.H(k.c,0,!1,s)))
s=k.z
s===$&&A.c("_network")
B.b.h(s,0,0)
B.b.h(k.z,1,0)
B.b.h(k.z,2,0)
B.b.h(k.z,3,255)
B.b.h(k.z,4,255)
B.b.h(k.z,5,255)
p=1/k.c
for(o=0;n=k.d,o<n;++o){s=k.ax
s===$&&A.c("_freq")
B.b.h(s,o,p)
s=k.at
s===$&&A.c("_bias")
B.b.h(s,o,0)}for(m=n*3,o=n;o<k.c;++o,m=l){l=m+1
B.b.h(k.z,m,255*(o-k.d)/k.f)
m=l+1
B.b.h(k.z,l,255*(o-k.d)/k.f)
l=m+1
B.b.h(k.z,m,255*(o-k.d)/k.f)
s=k.ax
s===$&&A.c("_freq")
B.b.h(s,o,p)
s=k.at
s===$&&A.c("_bias")
B.b.h(s,o,0)}},
hi(){var s,r,q,p,o,n,m,l,k,j
for(s=this.c,r=this.a,q=this.Q,p=0,o=0,n=0;p<s;++p,o=m){r===$&&A.c("colorMap")
m=o+1
q===$&&A.c("_colorMap")
l=n+2
k=q.length
if(!(l<k))return A.a(q,l)
l=q[l]
j=r.length
if(!(o<j))return A.a(r,o)
r[o]=Math.abs(l)&255
o=m+1
l=n+1
if(!(l<k))return A.a(q,l)
l=q[l]
if(!(m<j))return A.a(r,m)
r[m]=Math.abs(l)&255
m=o+1
if(!(n<k))return A.a(q,n)
k=q[n]
if(!(o<j))return A.a(r,o)
r[o]=Math.abs(k)&255
n+=4}},
e0(a,b,c){var s,r,q,p,o,n,m,l,k,j,i="_colorMap",h=this.as
if(!(b<256))return A.a(h,b)
s=h[b]
r=s-1
q=this.c
h=this.Q
p=1000
o=-1
while(!0){n=s<q
if(!(n||r>=0))break
if(n){m=s*4
h===$&&A.c(i)
n=m+1
l=h.length
if(!(n>=0&&n<l))return A.a(h,n)
k=h[n]-b
if(k>=p)s=q
else{if(k<0)k=-k
if(!(m>=0&&m<l))return A.a(h,m)
j=h[m]-a
k+=j<0?-j:j
if(k<p){n=m+2
if(!(n<l))return A.a(h,n)
j=h[n]-c
k+=j<0?-j:j
if(k<p){o=s
p=k}}++s}}if(r>=0){m=r*4
h===$&&A.c(i)
n=m+1
l=h.length
if(!(n>=0&&n<l))return A.a(h,n)
k=b-h[n]
if(k>=p)r=-1
else{if(k<0)k=-k
if(!(m>=0&&m<l))return A.a(h,m)
j=h[m]-a
k+=j<0?-j:j
if(k<p){n=m+2
if(!(n<l))return A.a(h,n)
j=h[n]-c
k+=j<0?-j:j
if(k<p){o=r
p=k}}--r}}}return o},
hW(){var s,r,q,p,o,n,m,l,k,j="_colorMap"
for(s=this.c,r=this.Q,q=this.z,p=0,o=0,n=0;p<s;++p,n+=4){for(m=0;m<3;++m,++o){q===$&&A.c("_network")
if(!(o>=0&&o<q.length))return A.a(q,o)
l=q[o]
if(typeof l!=="number")return A.D(l)
k=B.c.m(0.5+l)
if(k<0)k=0
if(k>255)k=255
r===$&&A.c(j)
l=n+m
if(!(l<r.length))return A.a(r,l)
r[l]=k}r===$&&A.c(j)
l=n+3
if(!(l<r.length))return A.a(r,l)
r[l]=p}},
ic(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b=this
for(s=b.c,r=b.Q,q=b.as,p=0,o=0,n=0,m=0;n<s;m=h,n=i){r===$&&A.c("_colorMap")
l=m+1
k=r.length
if(!(l<k))return A.a(r,l)
j=r[l]
for(i=n+1,h=m+4,g=h,f=i,e=n;f<s;++f,g+=4){d=g+1
if(!(d<k))return A.a(r,d)
c=r[d]
if(c<j){j=c
e=f}}g=e*4
if(n!==e){if(!(g<k))return A.a(r,g)
f=r[g]
if(!(m<k))return A.a(r,m)
r[g]=r[m]
r[m]=f
d=g+1
if(!(d<k))return A.a(r,d)
f=r[d]
r[d]=r[l]
r[l]=f
l=g+2
if(!(l<k))return A.a(r,l)
f=r[l]
d=m+2
if(!(d<k))return A.a(r,d)
r[l]=r[d]
r[d]=f
d=g+3
if(!(d<k))return A.a(r,d)
f=r[d]
l=m+3
if(!(l<k))return A.a(r,l)
r[d]=r[l]
r[l]=f}if(j!==p){if(!(p>=0&&p<256))return A.a(q,p)
q[p]=o+n>>>1
for(f=p+1;f<j;++f){if(!(f<256))return A.a(q,f)
q[f]=n}o=n
p=j}}s=b.r
s.toString
r=B.a.i(o+s,1)
if(!(p>=0&&p<256))return A.a(q,p)
q[p]=r
for(i=p+1;i<256;++i)q[i]=s},
es(a,b){var s,r,q,p
for(s=this.y,r=a*a,q=0;q<a;++q){s===$&&A.c("_radiusPower")
p=B.c.m(b*((r-q*q)*256/r))
if(!(q<s.length))return A.a(s,q)
s[q]=p}},
ii(a3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=this,a1="_network",a2=a0.x
a2===$&&A.c("initBiasRadius")
s=a0.b
r=30+B.a.F(s-1,3)
q=a3.x
p=q.length
o=B.a.V(p,s)
n=Math.max(B.a.F(o,100),1)
if(n===0)n=1
m=B.a.i(a2,8)
if(m<=1)m=0
a0.es(m,1024)
if(p<1509)l=a0.b=1
else if(B.a.I(p,499)!==0)l=499
else if(B.a.I(p,491)!==0)l=491
else l=B.a.I(p,487)!==0?487:503
for(k=a2,j=1024,i=0,h=0;h<o;){if(!(i>=0&&i<p))return A.a(q,i)
g=q[i]
f=g&255
e=g>>>8&255
d=g>>>16&255
if(h===0){a2=a0.z
a2===$&&A.c(a1)
s=a0.e
s===$&&A.c("bgColor")
B.b.h(a2,s*3,d)
B.b.h(a0.z,a0.e*3+1,e)
B.b.h(a0.z,a0.e*3+2,f)}c=a0.jf(d,e,f)
if(c<0)c=a0.hg(d,e,f)
if(c>=a0.d){b=j/1024
g=c*3
a2=a0.z
a2===$&&A.c(a1)
if(!(g>=0&&g<a2.length))return A.a(a2,g)
s=a2[g]
if(typeof s!=="number")return s.ac()
B.b.h(a2,g,s-b*(s-d))
s=a0.z
a2=g+1
if(!(a2<s.length))return A.a(s,a2)
a=s[a2]
if(typeof a!=="number")return a.ac()
B.b.h(s,a2,a-b*(a-e))
a=a0.z
a2=g+2
if(!(a2<a.length))return A.a(a,a2)
s=a[a2]
if(typeof s!=="number")return s.ac()
B.b.h(a,a2,s-b*(s-f))
if(m>0)a0.h4(b,m,c,d,e,f)}i+=l
for(;i>=p;)i-=p;++h
if(B.a.I(h,n)===0){j-=B.a.V(j,r)
k-=B.a.F(k,30)
m=B.a.i(k,8)
if(m<=1)m=0
a0.es(m,j)}}},
h4(a,b,c,d,a0,a1){var s,r,q,p,o,n,m,l,k,j,i,h=this,g="_network",f=c-b,e=h.d-1
if(f<e)f=e
s=c+b
r=h.c
if(s>r)s=r
q=c+1
p=c-1
o=1
while(!0){n=q<s
if(!(n||p>f))break
m=h.y
m===$&&A.c("_radiusPower")
l=o+1
if(!(o<m.length))return A.a(m,o)
k=m[o]
if(n){j=q*3
n=h.z
n===$&&A.c(g)
if(!(j>=0&&j<n.length))return A.a(n,j)
m=n[j]
if(typeof m!=="number")return m.ac()
B.b.h(n,j,m-k*(m-d)/262144)
m=h.z
n=j+1
if(!(n<m.length))return A.a(m,n)
i=m[n]
if(typeof i!=="number")return i.ac()
B.b.h(m,n,i-k*(i-a0)/262144)
i=h.z
n=j+2
if(!(n<i.length))return A.a(i,n)
m=i[n]
if(typeof m!=="number")return m.ac()
B.b.h(i,n,m-k*(m-a1)/262144);++q}if(p>f){j=p*3
n=h.z
n===$&&A.c(g)
if(!(j>=0&&j<n.length))return A.a(n,j)
m=n[j]
if(typeof m!=="number")return m.ac()
B.b.h(n,j,m-k*(m-d)/262144)
m=h.z
n=j+1
if(!(n<m.length))return A.a(m,n)
i=m[n]
if(typeof i!=="number")return i.ac()
B.b.h(m,n,i-k*(i-a0)/262144)
i=h.z
n=j+2
if(!(n<i.length))return A.a(i,n)
m=i[n]
if(typeof m!=="number")return m.ac()
B.b.h(i,n,m-k*(m-a1)/262144);--p}o=l}},
hg(a,b,c){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=this,d=1e30
for(s=e.d,r=s*3,q=d,p=q,o=-1,n=-1;s<e.c;++s,r=l){m=e.z
m===$&&A.c("_network")
l=r+1
k=m.length
if(!(r<k))return A.a(m,r)
j=m[r]
if(typeof j!=="number")return j.ac()
i=j-a
if(i<0)i=-i
r=l+1
if(!(l<k))return A.a(m,l)
j=m[l]
if(typeof j!=="number")return j.ac()
h=j-b
if(h<0)h=-h
l=r+1
if(!(r<k))return A.a(m,r)
m=m[r]
if(typeof m!=="number")return m.ac()
g=m-c
if(g<0)g=-g
i=i+h+g
if(i<p){o=s
p=i}m=e.at
m===$&&A.c("_bias")
if(!(s<m.length))return A.a(m,s)
f=i-m[s]
if(f<q){n=s
q=f}m=e.ax
m===$&&A.c("_freq")
if(!(s<m.length))return A.a(m,s)
k=m[s]
B.b.h(m,s,k-0.0009765625*k)
k=e.at
if(!(s<k.length))return A.a(k,s)
m=k[s]
j=e.ax
if(!(s<j.length))return A.a(j,s)
B.b.h(k,s,m+j[s])}m=e.ax
m===$&&A.c("_freq")
if(!(o>=0&&o<m.length))return A.a(m,o)
B.b.h(m,o,m[o]+0.0009765625)
m=e.at
m===$&&A.c("_bias")
if(!(o<m.length))return A.a(m,o)
B.b.h(m,o,m[o]-1)
return n},
jf(a,b,c){var s,r,q,p,o=this
for(s=0,r=0;s<o.d;++s){q=o.z
q===$&&A.c("_network")
p=r+1
if(!(r<q.length))return A.a(q,r)
if(J.au(q[r],a)){q=o.z
r=p+1
if(!(p<q.length))return A.a(q,p)
if(J.au(q[p],b)){q=o.z
p=r+1
if(!(r<q.length))return A.a(q,r)
q=J.au(q[r],c)
r=p}else q=!1}else{r=p
q=!1}if(q)return s}return-1},
skc(a){this.c=A.o(a)},
sfU(a){this.z=t.H.a(a)},
sfS(a){this.at=t.H.a(a)},
sfT(a){this.ax=t.H.a(a)}}
A.eL.prototype={
n(a){var s,r,q=this
if(q.a===q.c.length)q.hN()
s=q.c
r=q.a++
if(!(r>=0&&r<s.length))return A.a(s,r)
s[r]=a&255},
bT(a,b){var s,r,q,p,o=this
t.L.a(a)
if(b==null)b=J.b5(a)
for(;s=o.a,r=s+b,q=o.c,p=q.length,r>p;)o.dN(r-p)
B.e.az(q,s,r,a)
o.a+=b},
T(a){return this.bT(a,null)},
M(a){var s=this
if(s.b){s.n(B.a.i(a,8)&255)
s.n(a&255)
return}s.n(a&255)
s.n(B.a.i(a,8)&255)},
P(a){var s=this
if(s.b){s.n(B.a.i(a,24)&255)
s.n(B.a.i(a,16)&255)
s.n(B.a.i(a,8)&255)
s.n(a&255)
return}s.n(a&255)
s.n(B.a.i(a,8)&255)
s.n(B.a.i(a,16)&255)
s.n(B.a.i(a,24)&255)},
dN(a){var s,r,q,p
if(a!=null)s=a
else{r=this.c.length
s=r===0?8192:r*2}r=this.c
q=r.length
p=new Uint8Array(q+s)
B.e.az(p,0,q,r)
this.c=p},
hN(){return this.dN(null)},
gv(a){return this.a}}
A.hU.prototype={}
A.hD.prototype={
bn(a,b){var s,r
t.T.a(b)
s=A.nJ(a)
r=this.a.q(0,s)
r=B.hN.q(0,s)
if(r!=null)return r
return null}}
A.jw.prototype={
$0(){var s=$.ac
if(s!=null){s=s.c
if(s!=null)s.c8(700,"terminating Web worker")}s=this.a
s.port1.close()
s.port2.close()
this.b.close()},
$S:1}
A.jx.prototype={
$1(a){return this.a.bN(t.f.a(new A.fh([],[]).eF(t.e.a(a).data,!0)))},
$S:13}
A.jy.prototype={
$1(a){return this.a.ck(t.eO.a(new A.fh([],[]).eF(t.e.a(a).data,!0)),this.b.port2,this.c)},
$S:13}
A.iM.prototype={
b3(a,b){var s,r,q,p,o=t.gY.a(a).aR()
try{if(b){q=$.mD().cK(o,A.nH(t.K))
s=A.hA(q,!0,q.$ti.l("k.E"))
q=this.a
q.toString
B.aL.eQ(q,o,s)}else{q=this.a
q.toString
B.aL.kf(q,o)}}catch(p){r=A.a0(p)
A.lB("failed to post response "+A.v(o)+": error "+A.v(r))
throw p}}}
A.fp.prototype={
jR(a,b){var s,r=null,q=new A.j6(b),p=$.ac,o=p==null,n=o?r:p.c
if(n!=null)n.c8(1,q)
else if(o?$.bf:p.d){s=q.$0()
A.jM("[DEBUG] "+A.v(s))}q=A.kb(b,r)
this.b3(new A.bL(!1,q,r,r),!1)},
$ioO:1}
A.j6.prototype={
$0(){return"replying with error: "+this.a.u(0)},
$S:37}
A.f7.prototype={
ig(a){return a==null||typeof a=="string"||typeof a=="number"||A.dJ(a)},
cQ(a){if(a==null||typeof a=="string"||typeof a=="number"||A.dJ(a))return!0
if(t.in.b(a)||t.oT.b(a)||t.cq.b(a))return!0
if(t.j.b(a)&&J.n0(a,this.ge2()))return!0
if(t.f.b(a)&&a.gaN().b8(0,this.ge1())&&a.gaG().b8(0,this.ge2()))return!0
return!1},
cN(a,b){return this.i2(a,t.bF.a(b))},
i2(a,b){var s=this
return A.me(function(){var r=a,q=b
var p=0,o=1,n,m,l,k,j
return function $async$cN(c,d){if(c===1){n=d
p=o}while(true)switch(p){case 0:m=J.n4(r,new A.i5(s)),m=m.gZ(m),l=t.K
case 2:if(!m.C()){p=3
break}k=m.gH()
p=!q.aB(0,k)?4:5
break
case 4:j=k==null
q.A(0,j?l.a(k):k)
p=6
return j?l.a(k):k
case 6:case 5:p=2
break
case 3:return A.lU()
case 1:return A.lV(n)}}},t.K)},
cK(a,b){return this.hY(a,t.bF.a(b))},
hY(a,b){var s=this
return A.me(function(){var r=a,q=b
var p=0,o=2,n,m,l,k,j,i
return function $async$cK(c,d){if(c===1){n=d
p=o}while(true)switch(p){case 0:if(s.cQ(r)){p=1
break}if(!r.gaN().b8(0,s.ge1()))throw A.d(A.aI("Keys must be strings, numbers or booleans."))
m=A.b([],t.hf)
B.b.bE(m,s.cN(r.gaG(),q))
l=t.R,k=t.f
case 3:if(!(j=m.length,j!==0)){p=4
break}if(0>=j){A.a(m,-1)
p=1
break}i=m.pop()
p=k.b(i)?5:7
break
case 5:B.b.bE(m,s.cK(i,q))
p=6
break
case 7:p=l.b(i)?8:10
break
case 8:B.b.bE(m,s.cN(i,q))
p=9
break
case 10:p=11
return i
case 11:case 9:case 6:p=3
break
case 4:case 1:return A.lU()
case 2:return A.lV(n)}}},t.K)}}
A.i5.prototype={
$1(a){return!this.a.cQ(a)},
$S:5}
A.bV.prototype={
d1(){var s,r,q,p,o=this
if(o.b==null){s=A.n9(null,o.c,null,null)
o.b=s}s=o.d
if(s==null)s=B.av
r=s.length
q=t.Z
p=0
for(;p<s.length;s.length===r||(0,A.b3)(s),++p)A.my(q.a(s[p]))},
jp(a){var s
t.M.a(a)
if(this.b!=null)A.my(a)
else{s=this.d
if(s==null){s=A.b([],t.f7)
this.sij(s)}B.b.A(s,a)}},
kt(a){var s
t.M.a(a)
s=this.d
return s==null?null:B.b.bP(s,a)},
sij(a){this.d=t.gm.a(a)}}
A.hW.prototype={}
A.d5.prototype={
fF(a,b){var s
if(this.b==null)try{this.b=A.lC()}catch(s){}},
aR(){var s=this.b
s=s==null?null:s.u(0)
return["$",this.a,s]},
u(a){return B.a3.eI(this.aR(),null)},
$ibe:1}
A.be.prototype={
u(a){return B.a3.eI(this.aR(),null)}}
A.dS.prototype={
c8(a,b){var s,r,q,p,o,n,m,l=null
if(a<this.a)if(a===1){s=$.ac
s=s==null?$.bf:s.d}else s=!1
else s=!0
if(s){if(t.Y.b(b))b=b.$0()
s=new A.bx(Date.now(),!1).kB().kA()
r=A.nW(a)
q=$.ac
q=q==null?l:q.e
if(t.R.b(b)){p=J.n1(b,new A.fM(),t.N)
o=A.w(p)
n=o.l("cx<k.E,m>")
m=new A.W(new A.cx(p,o.l("k<m>(k.E)").a(new A.fN()),n),n.l("G(k.E)").a(new A.fO()),n.l("W<k.E>"))}else{m=b==null?l:new A.W(A.b(J.bR(b).split("\n"),t.s),t.gS.a(new A.fP()),t.cF)
if(m==null)m=B.du}for(p=J.aK(m),q="["+s+"] ["+r+"] ["+A.v(q)+"] ",r=this.b;p.C();){s=q+p.gH()
r.b3(new A.bL(!1,l,s,l),!1)}}},
$ilA:1}
A.fM.prototype={
$1(a){var s=a==null?null:J.bR(a)
return s==null?"":s},
$S:38}
A.fN.prototype={
$1(a){return A.b(A.a_(a).split("\n"),t.s)},
$S:39}
A.fO.prototype={
$1(a){return A.a_(a).length!==0},
$S:21}
A.fP.prototype={
$1(a){return A.a_(a).length!==0},
$S:21}
A.eM.prototype={}
A.ce.prototype={
cs(a,b,c,d){var s
if(this.b==null)try{this.b=A.lC()}catch(s){}},
aR(){var s=this,r=s.b
r=r==null?null:r.u(0)
return["$W",s.a,r,s.c,s.d]}}
A.bW.prototype={
aR(){var s=this,r=s.b
r=r==null?null:r.u(0)
return["$C",s.a,r,s.c,s.d]}}
A.f3.prototype={
aR(){var s,r,q,p=this,o=p.b
o=o==null?null:o.u(0)
s=p.c
r=p.d
q=p.x.gkO()
return["$T",p.a,o,s,r,q]},
$ilF:1}
A.aC.prototype={}
A.bL.prototype={
aR(){var s,r,q=this,p=q.b
if(p!=null){s=A.J(t.N,t.z)
s.h(0,"b",p.aR())
p=$.ac
if(p==null?$.bf:p.d)s.h(0,"d",1000*Date.now())
return s}else{p=q.d
if(p!=null){s=A.J(t.N,t.z)
s.h(0,"e",p)
p=$.ac
if(p==null?$.bf:p.d)s.h(0,"d",1000*Date.now())
return s}else if(q.a){p=A.J(t.N,t.z)
p.h(0,"c",!0)
s=$.ac
if(s==null?$.bf:s.d)p.h(0,"d",1000*Date.now())
return p}else{p=q.e
s=t.N
r=t.z
if(p==null){p=A.J(s,r)
s=$.ac
if(s==null?$.bf:s.d)p.h(0,"d",1000*Date.now())
return p}else{s=A.J(s,r)
s.h(0,"a",p)
p=$.ac
if(p==null?$.bf:p.d)s.h(0,"d",1000*Date.now())
return s}}}}}
A.b8.prototype={}
A.hV.prototype={}
A.iu.prototype={
dW(a){return a==null?$.mB():this.d.kj(a.a,new A.iv(a))},
sjh(a){this.e=t.fC.a(a)}}
A.iv.prototype={
$0(){var s=this.a.a,r=new A.b8(!0,++$.kC().a,null)
r.a=s
return r},
$S:41}
A.ix.prototype={
ck(a,b,c){return this.jC(a,b,t.by.a(c))},
jC(a2,a3,a4){var s=0,r=A.md(t.z),q=1,p,o=this,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1
var $async$ck=A.mi(function(a5,a6){if(a5===1){p=a6
s=q}while(true)switch(s){case 0:b=A.lP(a2)
a=b
a0=a==null?null:a.a
if(b==null)throw A.d(A.aI("connection request expected"))
else if(a0==null)throw A.d(A.aI("missing client for connection request"))
q=3
if(b.d!==-1){a=A.aI("connection request expected")
throw A.d(a)}else{a=o.a
if(a.a!==0){a=A.aI("already connected")
throw A.d(a)}}i=b.f
i.toString
h=A.kc()
if(h.e==null){g=B.d.kE(i)
if(g.length!==0)h.e=g}i=a0
h=A.kc()
if(h.f==null){h.f=i
f=$.ac
e=f==null
if(e)d=null
else{d=f.c
d=d==null?null:d.a}if(d==null)f=e?null:f.a
else f=d
h.c=new A.eM(i,f==null?2000:f)}i=b.r
i.toString
h=A.kc()
f=h.c
if(f!=null)f.a=i
h.a=i
i=b.x!=null
f=$.ac
if(f==null)$.bf=i
else f.d=i
n=null
m=a4.$1(b)
s=t.c.b(m)?6:8
break
case 6:s=9
return A.ks(m,$async$ck)
case 9:n=a6
s=7
break
case 8:n=m
case 7:l=n.gkd()
i=l
f=A.S(i).l("aA<1>")
f=new A.W(new A.aA(i,f),f.l("G(k.E)").a(new A.iy()),f.l("W<k.E>"))
if(!f.gal(f)){a=A.aI("invalid command identifier in service operations map; command ids must be > 0")
throw A.d(a)}a.bE(0,l)
a0.b3(A.iw(a3),!0)
q=1
s=5
break
case 3:q=2
a1=p
k=A.a0(a1)
j=A.an(a1)
J.kK(a0,A.kb(k,j))
s=5
break
case 2:s=1
break
case 5:return A.m8(null,r)
case 1:return A.m7(p,r)}})
return A.m9($async$ck,r)},
bN(a){return this.ki(a)},
ki(b0){var s=0,r=A.md(t.z),q,p=2,o,n=[],m=this,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9
var $async$bN=A.mi(function(b1,b2){if(b1===1){o=b2
s=p}while(true)switch(s){case 0:a6=A.lP(b0)
a7=a6
a8=a7==null?null:a7.a
if(a6==null)throw A.d(A.aI("invalid message"))
else if(a6.d===-4){a7=m.b
if(a7.c===0)a7.a.$0()
else a7.b=!0
q=null
s=1
break}else if(a6.d===-3){a7=a6.b
a7.toString
a7=m.b.dW(a7)
if(a7.e)a7.fi()
q=null
s=1
break}else if(a6.d===-2){a7=a6.c
a7.toString
b=m.b.e
if(b==null)a7=null
else{a7=b.q(0,a7)
a7=a7==null?null:a7.$0()}q=a7
s=1
break}else if(a8==null)throw A.d(A.aI("missing client for request: "+A.v(a6)))
a7=m.b
b=t.A.a(a6);++a7.c
a=a7.dW(b.b)
if(a.e){++a.f
a0=b.b
if(a0==null||a0.a!==a.a)A.F(A.aI("cancellation token mismatch"))
b.b=a}else if(b.b!=null)A.F(A.aI("Token reference mismatch"))
l=a
p=4
if(a6.d===-1){b=A.aI("unexpected connection request: "+b0.u(0))
throw A.d(b)}else{b=m.a
if(b.a===0){b=A.ki("worker service is not ready",null,null,null)
throw A.d(b)}}k=b.q(0,a6.d)
if(k==null){b=A.ki("unknown command: "+a6.d,null,null,null)
throw A.d(b)}j=k.$1(a6)
s=t.c.b(j)?7:8
break
case 7:s=9
return A.ks(j,$async$bN)
case 9:j=b2
case 8:i=a6.w
if(j instanceof A.cb){t.fw.a(j)
b=!0}else b=!1
s=b?10:12
break
case 10:h=A.ar("subscription")
g=new A.bM(new A.L($.C,t.d),t.jk)
f=new A.iB(a8,h,g)
b=t.m.a(l)
a0=t.M
a1=a0.a(f)
a2=++a7.f
a3=a7.e
if(a3==null){a0=A.J(t.p,a0)
a7.sjh(a0)}else a0=a3
a0.h(0,a2,a1)
if(b.e)b.fh(a1)
e=a2
a8.b3(A.iw(A.o(e)),!1)
b=h
a0=j
a1=A.S(a0)
a2=a1.l("~(1)?").a(new A.iz(a8,i))
t.Z.a(f)
a1=A.iQ(a0.a,a0.b,a2,!1,a1.c)
a0=b.b
if(a0==null?b!=null:a0!==b)A.F(new A.bD("Local '"+b.a+"' has already been initialized."))
b.b=a1
b=g.a
a4=t.O.a(new A.iA(m,l,e))
a0=b.$ti
j=new A.L($.C,a0)
b.bZ(new A.aY(j,8,a4,null,a0.l("@<1>").G(a0.c).l("aY<1,2>")))
s=13
return A.ks(j,$async$bN)
case 13:s=11
break
case 12:b=j
a0=A.m5(i)
a8.b3(A.iw(b),a0)
case 11:n.push(6)
s=5
break
case 4:p=3
a9=o
d=A.a0(a9)
c=A.an(a9)
J.kK(a8,A.kb(d,c))
n.push(6)
s=5
break
case 3:n=[2]
case 5:p=2
b=t.m.a(l)
if(b.e)--b.f
if(b.f===0&&b.b==null)a7.d.bP(0,b.a)
b=--a7.c
if(a7.b&&b===0)a7.a.$0()
s=n.pop()
break
case 6:case 1:return A.m8(q,r)
case 2:return A.m7(o,r)}})
return A.m9($async$bN,r)}}
A.iy.prototype={
$1(a){return A.o(a)<=0},
$S:42}
A.iB.prototype={
$0(){this.a.b3($.mQ(),!1)
this.b.K().d1()
this.c.jA()},
$S:1}
A.iz.prototype={
$1(a){return this.a.b3(A.iw(a),this.b)},
$S:4}
A.iA.prototype={
$0(){var s=this.a.b,r=this.b,q=this.c,p=s.e,o=p==null?null:p.q(0,q)
if(o!=null){t.M.a(o)
if(r.e)r.fj(o)
s=s.e
if(s!=null)s.bP(0,q)}},
$S:7};(function aliases(){var s=J.bb.prototype
s.fq=s.u
s=A.ap.prototype
s.fm=s.eJ
s.fn=s.eK
s.fp=s.eM
s.fo=s.eL
s=A.q.prototype
s.dl=s.U
s=A.k.prototype
s.fl=s.bb
s=A.aN.prototype
s.fk=s.d_
s=A.bV.prototype
s.fi=s.d1
s.fh=s.jp
s.fj=s.kt})();(function installTearOffs(){var s=hunkHelpers._static_1,r=hunkHelpers._static_0,q=hunkHelpers._static_2,p=hunkHelpers._instance_2u,o=hunkHelpers._instance_1u,n=hunkHelpers.installStaticTearOff
s(A,"pE","nt",20)
s(A,"pR","oQ",8)
s(A,"pS","oR",8)
s(A,"pT","oS",8)
r(A,"mk","pK",1)
q(A,"mm","pm",45)
s(A,"pW","pn",20)
s(A,"mn","po",12)
var m
p(m=A.ev.prototype,"ghp","hq",10)
p(m,"ghs","ht",10)
p(m,"ghu","hv",15)
p(m,"ghk","hl",10)
p(m,"ghm","hn",15)
s(A,"qI","oo",0)
s(A,"qz","of",0)
s(A,"qs","o8",0)
s(A,"qF","ol",0)
s(A,"qG","om",0)
s(A,"qE","ok",0)
s(A,"qD","oj",0)
s(A,"qC","oi",0)
s(A,"qL","or",0)
s(A,"qK","oq",0)
s(A,"qB","oh",0)
s(A,"qx","od",0)
s(A,"qH","on",0)
s(A,"qy","oe",0)
s(A,"qo","o4",0)
s(A,"qq","o6",0)
s(A,"qp","o5",0)
s(A,"qr","o7",0)
s(A,"qJ","op",0)
s(A,"qA","og",0)
s(A,"qt","o9",0)
s(A,"qu","oa",0)
s(A,"qv","ob",0)
s(A,"qw","oc",0)
o(A.dd.prototype,"giG","iH",11)
o(A.eo.prototype,"gjS","jT",11)
n(A,"kB",3,null,["$3"],["ot"],2,0)
n(A,"qM",3,null,["$3"],["ou"],2,0)
n(A,"qR",3,null,["$3"],["oz"],2,0)
n(A,"qS",3,null,["$3"],["oA"],2,0)
n(A,"qT",3,null,["$3"],["oB"],2,0)
n(A,"qU",3,null,["$3"],["oC"],2,0)
n(A,"qV",3,null,["$3"],["oD"],2,0)
n(A,"qW",3,null,["$3"],["oE"],2,0)
n(A,"qX",3,null,["$3"],["oF"],2,0)
n(A,"qY",3,null,["$3"],["oG"],2,0)
n(A,"qN",3,null,["$3"],["ov"],2,0)
n(A,"qO",3,null,["$3"],["ow"],2,0)
n(A,"qP",3,null,["$3"],["ox"],2,0)
n(A,"qQ",3,null,["$3"],["oy"],2,0)
o(m=A.f7.prototype,"ge1","ig",5)
o(m,"ge2","cQ",5)
n(A,"r_",6,null,["$6"],["oM"],9,0)
n(A,"r0",6,null,["$6"],["oN"],9,0)
n(A,"qZ",6,null,["$6"],["oL"],9,0)})();(function inheritance(){var s=hunkHelpers.mixin,r=hunkHelpers.inherit,q=hunkHelpers.inheritMany
r(A.t,null)
q(A.t,[A.jZ,J.eg,J.bv,A.x,A.dr,A.b9,A.k,A.bF,A.I,A.cy,A.cu,A.a2,A.bk,A.bX,A.i6,A.hH,A.cw,A.dA,A.Y,A.hy,A.bE,A.et,A.iN,A.aB,A.fo,A.dD,A.ji,A.fj,A.cg,A.bo,A.cr,A.fm,A.aY,A.L,A.fk,A.cb,A.f_,A.f0,A.fu,A.dH,A.dI,A.fr,A.bN,A.q,A.dt,A.d4,A.iL,A.aL,A.av,A.ja,A.j7,A.f2,A.jm,A.fC,A.bx,A.iO,A.eK,A.d6,A.iS,A.e6,A.K,A.fv,A.bh,A.i8,A.jR,A.jf,A.iF,A.hG,A.ef,A.hK,A.iD,A.fY,A.as,A.j4,A.ft,A.ha,A.ed,A.iC,A.iE,A.c4,A.bZ,A.fQ,A.fX,A.a9,A.h0,A.e2,A.aO,A.e3,A.e4,A.e5,A.dy,A.e7,A.cE,A.c2,A.dX,A.hq,A.az,A.hr,A.ch,A.eu,A.hu,A.ev,A.cZ,A.aG,A.c9,A.hQ,A.bH,A.eR,A.d1,A.i2,A.f5,A.i3,A.f6,A.hB,A.ic,A.dc,A.id,A.ij,A.io,A.iq,A.db,A.ip,A.ie,A.aW,A.de,A.fg,A.df,A.dg,A.dd,A.fe,A.ik,A.ff,A.is,A.di,A.ea,A.c0,A.e9,A.cF,A.hc,A.c3,A.hg,A.a3,A.hU,A.eL,A.hD,A.iM,A.f7,A.bV,A.hW,A.d5,A.be,A.dS,A.aC,A.bL,A.hV,A.iu,A.ix])
q(J.eg,[J.er,J.cO,J.ay,J.p,J.c5,J.c6,A.cV,A.N])
q(J.ay,[J.bb,A.bw,A.aN,A.h_,A.i])
q(J.bb,[J.eN,J.bI,J.aQ])
r(J.hp,J.p)
q(J.c5,[J.cN,J.es])
q(A.x,[A.bD,A.bi,A.ew,A.f9,A.eY,A.cq,A.fn,A.cP,A.eJ,A.aF,A.fa,A.f8,A.ca,A.dY,A.dZ])
r(A.cS,A.dr)
r(A.cc,A.cS)
r(A.a8,A.cc)
q(A.b9,[A.dV,A.fW,A.h5,A.dW,A.f4,A.hw,A.jF,A.jH,A.iI,A.iH,A.jp,A.iW,A.j3,A.hY,A.je,A.jc,A.iR,A.jN,A.jO,A.jJ,A.hh,A.hi,A.hj,A.hk,A.fV,A.fT,A.h2,A.hf,A.hs,A.hM,A.hm,A.hl,A.jx,A.jy,A.i5,A.fM,A.fN,A.fO,A.fP,A.iy,A.iz])
q(A.dV,[A.jL,A.iJ,A.iK,A.jj,A.iT,A.j_,A.iY,A.iV,A.iZ,A.iU,A.j2,A.j1,A.j0,A.hZ,A.ju,A.jd,A.ib,A.ia,A.h7,A.jw,A.j6,A.iv,A.iB,A.iA])
q(A.k,[A.r,A.aR,A.W,A.cx,A.dl,A.cM])
q(A.r,[A.X,A.bz,A.aA,A.ds])
q(A.X,[A.d7,A.aS,A.dn])
r(A.by,A.aR)
q(A.I,[A.cU,A.dk])
q(A.bX,[A.ct,A.cC])
r(A.cY,A.bi)
q(A.f4,[A.eZ,A.bU])
r(A.fi,A.cq)
r(A.cT,A.Y)
r(A.ap,A.cT)
q(A.dW,[A.hv,A.jG,A.jq,A.jv,A.iX,A.hz,A.hC,A.jb,A.j8,A.i9,A.jg,A.jh,A.iG,A.ir,A.jE,A.jD])
r(A.U,A.N)
q(A.U,[A.du,A.dw])
r(A.dv,A.du)
r(A.bd,A.dv)
r(A.dx,A.dw)
r(A.aj,A.dx)
q(A.bd,[A.eD,A.eE])
q(A.aj,[A.eF,A.eG,A.eH,A.eI,A.cW,A.cX,A.bG])
r(A.dE,A.fn)
r(A.dC,A.cM)
r(A.bM,A.fm)
r(A.fs,A.dH)
r(A.dp,A.ap)
r(A.dz,A.dI)
r(A.dq,A.dz)
r(A.aw,A.f0)
q(A.aw,[A.fy,A.fx,A.dR,A.ez,A.fd,A.fc])
r(A.b7,A.aL)
q(A.b7,[A.dT,A.fD])
r(A.fl,A.dT)
r(A.fB,A.fl)
q(A.av,[A.e1,A.ex])
r(A.ey,A.cP)
r(A.fq,A.ja)
r(A.fE,A.fq)
r(A.j9,A.fE)
q(A.e1,[A.eA,A.fb])
r(A.eC,A.fy)
r(A.eB,A.fx)
r(A.f1,A.f2)
r(A.dB,A.f1)
q(A.aF,[A.d3,A.ec])
q(A.aN,[A.bm,A.bc])
r(A.bY,A.bm)
r(A.c_,A.bw)
r(A.aT,A.i)
r(A.iP,A.cb)
r(A.dm,A.f_)
r(A.fw,A.jf)
r(A.fh,A.iF)
r(A.fJ,A.e6)
r(A.ee,A.ef)
r(A.hI,A.hK)
r(A.jo,A.iD)
q(A.iO,[A.cs,A.hb,A.h3,A.dU,A.fS,A.fZ,A.e0,A.cL])
q(A.fX,[A.b6,A.h1,A.e8,A.he,A.hO,A.hR,A.i1,A.i4,A.dj])
q(A.a9,[A.bT,A.cz,A.cD,A.cG,A.c7,A.c8,A.d0,A.d8,A.d9,A.dh])
r(A.e_,A.bT)
q(A.h0,[A.fU,A.h6,A.it,A.ht,A.hN,A.i0])
r(A.eh,A.aO)
q(A.eh,[A.cH,A.ei,A.ej,A.ek,A.cJ])
r(A.cI,A.e5)
r(A.el,A.cE)
r(A.eb,A.b6)
r(A.hd,A.it)
r(A.em,A.cZ)
r(A.en,A.hO)
q(A.aG,[A.eP,A.eQ,A.eS,A.eT,A.eV,A.eW])
q(A.c9,[A.d2,A.eU])
r(A.eo,A.dd)
r(A.ep,A.di)
r(A.cK,A.dj)
r(A.hF,A.hU)
r(A.fp,A.iM)
r(A.eM,A.dS)
r(A.ce,A.be)
r(A.bW,A.ce)
r(A.f3,A.bW)
r(A.b8,A.bV)
s(A.cc,A.bk)
s(A.du,A.q)
s(A.dv,A.a2)
s(A.dw,A.q)
s(A.dx,A.a2)
s(A.dr,A.q)
s(A.dI,A.d4)
s(A.fE,A.j7)})()
var v={typeUniverse:{eC:new Map(),tR:{},eT:{},tPV:{},sEA:[]},mangledGlobalNames:{e:"int",y:"double",E:"num",m:"String",G:"bool",K:"Null",h:"List"},mangledNames:{},types:["~(a3)","~()","e(aV,e,e)","m?/(aC)","~(@)","G(@)","~(t?,t?)","K()","~(~())","~(e,e,e,e,e,bj)","~(az,h<@>)","~(e)","@(@)","~(aT)","E(E,E)","~(az,h<e>)","K(@)","~(@,@)","@()","e(e)","e(t?)","G(m)","c4(aC)","K(@,@)","~(i)","~(m,m)","aV(e)","e()","c2(e)","az(e)","ax<K>()","L<@>(@)","K(t,bg)","~(e,@)","e(e,e,e,e)","E(E,E,E,E,E)","K(@,bg)","m()","m(@)","h<m>(m)","e(e,e)","b8()","G(e)","K(~())","@(m)","G(t?,t?)","@(@,m)","G(t?)","@(@,@)"],interceptorsByTag:null,leafTags:null,arrayRti:Symbol("$ti")}
A.pb(v.typeUniverse,JSON.parse('{"eN":"bb","bI":"bb","aQ":"bb","r1":"i","r4":"i","r8":"bm","r6":"N","er":{"G":[]},"cO":{"K":[]},"bb":{"la":[]},"p":{"h":["1"],"r":["1"],"k":["1"]},"hp":{"p":["1"],"h":["1"],"r":["1"],"k":["1"]},"bv":{"I":["1"]},"c5":{"y":[],"E":[]},"cN":{"y":[],"e":[],"E":[]},"es":{"y":[],"E":[]},"c6":{"m":[],"hL":[]},"bD":{"x":[]},"a8":{"q":["e"],"bk":["e"],"h":["e"],"r":["e"],"k":["e"],"q.E":"e","bk.E":"e"},"r":{"k":["1"]},"X":{"r":["1"],"k":["1"]},"d7":{"X":["1"],"r":["1"],"k":["1"],"k.E":"1","X.E":"1"},"bF":{"I":["1"]},"aR":{"k":["2"],"k.E":"2"},"by":{"aR":["1","2"],"r":["2"],"k":["2"],"k.E":"2"},"cU":{"I":["2"]},"aS":{"X":["2"],"r":["2"],"k":["2"],"k.E":"2","X.E":"2"},"W":{"k":["1"],"k.E":"1"},"dk":{"I":["1"]},"cx":{"k":["2"],"k.E":"2"},"cy":{"I":["2"]},"bz":{"r":["1"],"k":["1"],"k.E":"1"},"cu":{"I":["1"]},"cc":{"q":["1"],"bk":["1"],"h":["1"],"r":["1"],"k":["1"]},"bX":{"aa":["1","2"]},"ct":{"bX":["1","2"],"aa":["1","2"]},"dl":{"k":["1"],"k.E":"1"},"cC":{"bX":["1","2"],"aa":["1","2"]},"cY":{"bi":[],"x":[]},"ew":{"x":[]},"f9":{"x":[]},"dA":{"bg":[]},"b9":{"bA":[]},"dV":{"bA":[]},"dW":{"bA":[]},"f4":{"bA":[]},"eZ":{"bA":[]},"bU":{"bA":[]},"eY":{"x":[]},"fi":{"x":[]},"ap":{"Y":["1","2"],"k0":["1","2"],"aa":["1","2"],"Y.K":"1","Y.V":"2"},"aA":{"r":["1"],"k":["1"],"k.E":"1"},"bE":{"I":["1"]},"et":{"lw":[],"hL":[]},"N":{"V":[]},"U":{"ai":["1"],"N":[],"V":[]},"bd":{"U":["y"],"q":["y"],"ai":["y"],"h":["y"],"N":[],"r":["y"],"V":[],"k":["y"],"a2":["y"]},"aj":{"U":["e"],"q":["e"],"ai":["e"],"h":["e"],"N":[],"r":["e"],"V":[],"k":["e"],"a2":["e"]},"eD":{"bd":[],"U":["y"],"q":["y"],"nq":[],"ai":["y"],"h":["y"],"N":[],"r":["y"],"V":[],"k":["y"],"a2":["y"],"q.E":"y"},"eE":{"bd":[],"U":["y"],"q":["y"],"ai":["y"],"h":["y"],"N":[],"r":["y"],"V":[],"k":["y"],"a2":["y"],"q.E":"y"},"eF":{"aj":[],"U":["e"],"q":["e"],"jW":[],"ai":["e"],"h":["e"],"N":[],"r":["e"],"V":[],"k":["e"],"a2":["e"],"q.E":"e"},"eG":{"aj":[],"U":["e"],"q":["e"],"ho":[],"ai":["e"],"h":["e"],"N":[],"r":["e"],"V":[],"k":["e"],"a2":["e"],"q.E":"e"},"eH":{"aj":[],"U":["e"],"q":["e"],"nA":[],"ai":["e"],"h":["e"],"N":[],"r":["e"],"V":[],"k":["e"],"a2":["e"],"q.E":"e"},"eI":{"aj":[],"U":["e"],"q":["e"],"nY":[],"ai":["e"],"h":["e"],"N":[],"r":["e"],"V":[],"k":["e"],"a2":["e"],"q.E":"e"},"cW":{"aj":[],"U":["e"],"q":["e"],"aV":[],"ai":["e"],"h":["e"],"N":[],"r":["e"],"V":[],"k":["e"],"a2":["e"],"q.E":"e"},"cX":{"aj":[],"U":["e"],"q":["e"],"ai":["e"],"h":["e"],"N":[],"r":["e"],"V":[],"k":["e"],"a2":["e"],"q.E":"e"},"bG":{"aj":[],"U":["e"],"q":["e"],"bj":[],"ai":["e"],"h":["e"],"N":[],"r":["e"],"V":[],"k":["e"],"a2":["e"],"q.E":"e"},"dD":{"lG":[]},"fn":{"x":[]},"dE":{"bi":[],"x":[]},"L":{"ax":["1"]},"bo":{"I":["1"]},"dC":{"k":["1"],"k.E":"1"},"cr":{"x":[]},"bM":{"fm":["1"]},"dH":{"lR":[]},"fs":{"dH":[],"lR":[]},"dp":{"ap":["1","2"],"Y":["1","2"],"k0":["1","2"],"aa":["1","2"],"Y.K":"1","Y.V":"2"},"dq":{"d4":["1"],"ka":["1"],"r":["1"],"k":["1"]},"bN":{"I":["1"]},"cM":{"k":["1"]},"cS":{"q":["1"],"h":["1"],"r":["1"],"k":["1"]},"cT":{"Y":["1","2"],"aa":["1","2"]},"Y":{"aa":["1","2"]},"ds":{"r":["2"],"k":["2"],"k.E":"2"},"dt":{"I":["2"]},"dz":{"d4":["1"],"ka":["1"],"r":["1"],"k":["1"]},"fy":{"aw":["m","h<e>"]},"fx":{"aw":["h<e>","m"]},"dR":{"aw":["h<e>","m"]},"fl":{"b7":[],"aL":["h<e>"],"aH":["h<e>"]},"fB":{"b7":[],"aL":["h<e>"],"aH":["h<e>"]},"b7":{"aL":["h<e>"],"aH":["h<e>"]},"dT":{"b7":[],"aL":["h<e>"],"aH":["h<e>"]},"aL":{"aH":["1"]},"e1":{"av":["m","h<e>"]},"cP":{"x":[]},"ey":{"x":[]},"ex":{"av":["t?","m"],"av.S":"t?"},"ez":{"aw":["t?","m"]},"eA":{"av":["m","h<e>"],"av.S":"m"},"eC":{"aw":["m","h<e>"]},"eB":{"aw":["h<e>","m"]},"f1":{"aH":["m"]},"f2":{"aH":["m"]},"dB":{"aH":["m"]},"fD":{"b7":[],"aL":["h<e>"],"aH":["h<e>"]},"fb":{"av":["m","h<e>"],"av.S":"m"},"fd":{"aw":["m","h<e>"]},"fc":{"aw":["h<e>","m"]},"y":{"E":[]},"e":{"E":[]},"h":{"r":["1"],"k":["1"]},"m":{"hL":[]},"cq":{"x":[]},"bi":{"x":[]},"eJ":{"x":[]},"aF":{"x":[]},"d3":{"x":[]},"ec":{"x":[]},"fa":{"x":[]},"f8":{"x":[]},"ca":{"x":[]},"dY":{"x":[]},"eK":{"x":[]},"d6":{"x":[]},"dZ":{"x":[]},"dn":{"X":["1"],"r":["1"],"k":["1"],"k.E":"1","X.E":"1"},"fv":{"bg":[]},"bh":{"lE":[]},"aT":{"i":[]},"bY":{"aN":[]},"c_":{"bw":[]},"bc":{"aN":[]},"bm":{"aN":[]},"iP":{"cb":["1"]},"dm":{"f_":["1"]},"ee":{"ef":[]},"c4":{"lQ":[]},"bT":{"a9":[]},"e_":{"a9":[]},"cH":{"aO":[]},"eh":{"aO":[]},"cI":{"e5":[]},"ei":{"aO":[]},"ej":{"aO":[]},"ek":{"aO":[]},"cJ":{"aO":[]},"cz":{"a9":[]},"el":{"cE":[]},"cD":{"a9":[]},"cG":{"a9":[]},"eb":{"b6":[]},"c7":{"a9":[]},"em":{"cZ":[]},"c8":{"a9":[]},"eP":{"aG":[]},"eQ":{"aG":[]},"eS":{"aG":[]},"eT":{"aG":[]},"eV":{"aG":[]},"eW":{"aG":[]},"d2":{"c9":[]},"eU":{"c9":[]},"d0":{"a9":[]},"d8":{"a9":[]},"d9":{"a9":[]},"ep":{"di":[]},"cK":{"dj":[]},"dh":{"a9":[]},"fp":{"oO":[]},"d5":{"be":[]},"dS":{"lA":[]},"eM":{"lA":[]},"ce":{"be":[]},"bW":{"be":[]},"f3":{"bW":[],"be":[],"lF":[]},"b8":{"bV":[]},"bj":{"h":["e"],"r":["e"],"k":["e"],"V":[]},"jW":{"h":["e"],"r":["e"],"k":["e"],"V":[]},"ho":{"h":["e"],"r":["e"],"k":["e"],"V":[]},"aV":{"h":["e"],"r":["e"],"k":["e"],"V":[]}}'))
A.pa(v.typeUniverse,JSON.parse('{"r":1,"cc":1,"U":1,"f0":2,"cM":1,"cS":1,"cT":2,"dz":1,"dr":1,"dI":1}'))
var u={c:"EOF reached without finding string terminator",b:"Error handler must accept one Object or one Object and a StackTrace as arguments, and return a value of the returned future's type"}
var t=(function rtii(){var s=A.b1
return{n:s("cr"),G:s("cs"),fj:s("bw"),m:s("b8"),dd:s("bY"),gt:s("r<@>"),Q:s("x"),V:s("i"),iW:s("e2"),ho:s("e4"),et:s("c_"),Y:s("bA"),by:s("lQ/(aC)"),c:s("ax<@>"),co:s("c0"),r:s("cF"),gP:s("ea"),aw:s("c2"),bW:s("ho"),id:s("k<y>"),R:s("k<@>"),fm:s("k<e>"),an:s("p<dX>"),a_:s("p<e3>"),b:s("p<cE>"),W:s("p<c0>"),jI:s("p<c3>"),hz:s("p<cI>"),hc:s("p<h<h<h<e>>>>"),o:s("p<h<h<e>>>"),S:s("p<h<e>>"),U:s("p<h<E>>"),hf:s("p<t>"),fi:s("p<cZ>"),mS:s("p<bH>"),na:s("p<aG>"),k9:s("p<d1>"),s:s("p<m>"),fZ:s("p<f6>"),i:s("p<bj>"),hP:s("p<aW>"),ip:s("p<ff>"),J:s("p<di>"),kv:s("p<ch>"),dG:s("p<@>"),t:s("p<e>"),gU:s("p<eu?>"),lv:s("p<h<@>?>"),iZ:s("p<h<e>?>"),mD:s("p<aV?>"),a:s("p<E>"),f7:s("p<~()>"),B:s("p<~(a3)>"),u:s("cO"),bp:s("la"),dY:s("aQ"),dX:s("ai<@>"),e7:s("az"),kk:s("h<c0>"),aL:s("h<c3>"),kn:s("h<ho>"),hK:s("h<h<h<e>>>"),mL:s("h<h<aW>>"),ez:s("h<t>"),I:s("h<bH>"),f0:s("h<d1>"),in:s("h<m>"),ac:s("h<db>"),jz:s("h<aW>"),jt:s("h<de>"),as:s("h<df>"),f4:s("h<dg>"),cq:s("h<G>"),H:s("h<y>"),j:s("h<@>"),L:s("h<e>"),w:s("h<h<e>?>"),kb:s("h<aW?>"),a3:s("h<dy?>"),dW:s("h<e?>"),oT:s("h<E>"),je:s("aa<m,m>"),f:s("aa<@,@>"),cG:s("aa<e,@(aC)>"),e:s("aT"),oA:s("bc"),hH:s("cV"),dQ:s("bd"),aj:s("aj"),hX:s("N"),hD:s("bG"),P:s("K"),K:s("t"),dS:s("bH"),ok:s("eR"),dM:s("d2"),mi:s("c9"),kl:s("lw"),bF:s("ka<t>"),i3:s("aH<m>"),l:s("bg"),fw:s("cb<@>"),N:s("m"),e8:s("f5"),on:s("lF"),ha:s("lG"),do:s("bi"),bl:s("V"),mC:s("aV"),D:s("bj"),cx:s("bI"),aO:s("db"),f_:s("de"),h2:s("df"),ij:s("dg"),cF:s("W<m>"),A:s("aC"),gY:s("bL"),jk:s("bM<@>"),av:s("L<K>"),d:s("L<@>"),hy:s("L<e>"),nA:s("dy"),aK:s("ft"),nn:s("dB<lE>"),v:s("G"),nU:s("G(t)"),gS:s("G(m)"),dx:s("y"),z:s("@"),O:s("@()"),E:s("@(t)"),C:s("@(t,bg)"),g9:s("@(aC)"),p1:s("@(@,@)"),p:s("e"),eK:s("0&*"),_:s("t*"),gK:s("ax<K>?"),jH:s("jW?"),nW:s("h<t>?"),jj:s("h<bj>?"),lH:s("h<@>?"),T:s("h<e>?"),h:s("h<h<e>?>?"),lq:s("h<aV?>?"),k:s("h<e?>?"),gm:s("h<~()>?"),lG:s("aa<m,m>?"),eO:s("aa<@,@>?"),fC:s("aa<e,~()>?"),hk:s("bc?"),X:s("t?"),jv:s("m?"),nh:s("bj?"),nX:s("dc?"),fA:s("aW?"),nk:s("fg?"),F:s("aY<@,@>?"),g:s("fr?"),y:s("@(i)?"),x:s("e?"),lN:s("t?(@)?"),Z:s("~()?"),m1:s("~(aT)?"),bZ:s("~(e)?"),cZ:s("E"),q:s("~"),M:s("~()"),mX:s("~(az,h<e>)"),lt:s("~(e)")}})();(function constants(){var s=hunkHelpers.makeConstList
B.b0=J.eg.prototype
B.b=J.p.prototype
B.a=J.cN.prototype
B.c=J.c5.prototype
B.d=J.c6.prototype
B.b4=J.aQ.prototype
B.b5=J.ay.prototype
B.aL=A.bc.prototype
B.n=A.cW.prototype
B.e=A.bG.prototype
B.aM=J.eN.prototype
B.a_=J.bI.prototype
B.N=new A.cs(0,"BI_BITFIELDS")
B.O=new A.cs(1,"NONE")
B.aO=new A.fS(1,"over")
B.aP=new A.dR()
B.a0=new A.cu(A.b1("cu<0&>"))
B.a1=function getTagFallback(o) {
  var s = Object.prototype.toString.call(o);
  return s.substring(8, s.length - 1);
}
B.aQ=function() {
  var toStringFunction = Object.prototype.toString;
  function getTag(o) {
    var s = toStringFunction.call(o);
    return s.substring(8, s.length - 1);
  }
  function getUnknownTag(object, tag) {
    if (/^HTML[A-Z].*Element$/.test(tag)) {
      var name = toStringFunction.call(object);
      if (name == "[object Object]") return null;
      return "HTMLElement";
    }
  }
  function getUnknownTagGenericBrowser(object, tag) {
    if (self.HTMLElement && object instanceof HTMLElement) return "HTMLElement";
    return getUnknownTag(object, tag);
  }
  function prototypeForTag(tag) {
    if (typeof window == "undefined") return null;
    if (typeof window[tag] == "undefined") return null;
    var constructor = window[tag];
    if (typeof constructor != "function") return null;
    return constructor.prototype;
  }
  function discriminator(tag) { return null; }
  var isBrowser = typeof navigator == "object";
  return {
    getTag: getTag,
    getUnknownTag: isBrowser ? getUnknownTagGenericBrowser : getUnknownTag,
    prototypeForTag: prototypeForTag,
    discriminator: discriminator };
}
B.aV=function(getTagFallback) {
  return function(hooks) {
    if (typeof navigator != "object") return hooks;
    var ua = navigator.userAgent;
    if (ua.indexOf("DumpRenderTree") >= 0) return hooks;
    if (ua.indexOf("Chrome") >= 0) {
      function confirm(p) {
        return typeof window == "object" && window[p] && window[p].name == p;
      }
      if (confirm("Window") && confirm("HTMLElement")) return hooks;
    }
    hooks.getTag = getTagFallback;
  };
}
B.aR=function(hooks) {
  if (typeof dartExperimentalFixupGetTag != "function") return hooks;
  hooks.getTag = dartExperimentalFixupGetTag(hooks.getTag);
}
B.aS=function(hooks) {
  var getTag = hooks.getTag;
  var prototypeForTag = hooks.prototypeForTag;
  function getTagFixed(o) {
    var tag = getTag(o);
    if (tag == "Document") {
      if (!!o.xmlVersion) return "!Document";
      return "!HTMLDocument";
    }
    return tag;
  }
  function prototypeForTagFixed(tag) {
    if (tag == "Document") return null;
    return prototypeForTag(tag);
  }
  hooks.getTag = getTagFixed;
  hooks.prototypeForTag = prototypeForTagFixed;
}
B.aU=function(hooks) {
  var userAgent = typeof navigator == "object" ? navigator.userAgent : "";
  if (userAgent.indexOf("Firefox") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "GeoGeolocation": "Geolocation",
    "Location": "!Location",
    "WorkerMessageEvent": "MessageEvent",
    "XMLDocument": "!Document"};
  function getTagFirefox(o) {
    var tag = getTag(o);
    return quickMap[tag] || tag;
  }
  hooks.getTag = getTagFirefox;
}
B.aT=function(hooks) {
  var userAgent = typeof navigator == "object" ? navigator.userAgent : "";
  if (userAgent.indexOf("Trident/") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "HTMLDDElement": "HTMLElement",
    "HTMLDTElement": "HTMLElement",
    "HTMLPhraseElement": "HTMLElement",
    "Position": "Geoposition"
  };
  function getTagIE(o) {
    var tag = getTag(o);
    var newTag = quickMap[tag];
    if (newTag) return newTag;
    if (tag == "Object") {
      if (window.DataView && (o instanceof window.DataView)) return "DataView";
    }
    return tag;
  }
  function prototypeForTagIE(tag) {
    var constructor = window[tag];
    if (constructor == null) return null;
    return constructor.prototype;
  }
  hooks.getTag = getTagIE;
  hooks.prototypeForTag = prototypeForTagIE;
}
B.a2=function(hooks) { return hooks; }

B.a3=new A.ex()
B.a4=new A.eA()
B.a5=new A.eC()
B.aW=new A.eK()
B.t=new A.fb()
B.aX=new A.fd()
B.hZ=new A.iC()
B.a6=new A.iE()
B.h=new A.fs()
B.aY=new A.fv()
B.u=new A.jo()
B.o=new A.dU(0,"rgb")
B.f=new A.dU(1,"rgba")
B.aZ=new A.fZ(1,"clear")
B.b_=new A.e0(0,"None")
B.a7=new A.e0(2,"FloydSteinberg")
B.i_=new A.h3(2,"rgba")
B.P=new A.hb(1,"deflate")
B.b1=new A.cL(0,"nearest")
B.b2=new A.cL(1,"linear")
B.b3=new A.cL(2,"cubic")
B.b6=new A.ez(null,null)
B.b7=new A.eB(!1)
B.Q=A.b(s([A.qt(),A.qG(),A.qJ(),A.qA(),A.qv(),A.qu(),A.qw()]),t.B)
B.y=A.b(s([0,2,8]),t.t)
B.be=A.b(s([0,4,2,1]),t.t)
B.z=A.b(s([292,260,226,226]),t.t)
B.a8=A.b(s([8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,8,8,8,8,8,8,8,8]),t.t)
B.a9=A.b(s([137,80,78,71,13,10,26,10]),t.t)
B.aa=A.b(s([2,3,7]),t.t)
B.bx=A.b(s([3,3,11]),t.t)
B.ac=A.b(s([511,1023,2047,4095]),t.t)
B.cB=A.b(s([231,120,48,89,115,113,120,152,112]),t.t)
B.fr=A.b(s([152,179,64,126,170,118,46,70,95]),t.t)
B.fs=A.b(s([175,69,143,80,85,82,72,155,103]),t.t)
B.ft=A.b(s([56,58,10,171,218,189,17,13,152]),t.t)
B.fE=A.b(s([114,26,17,163,44,195,21,10,173]),t.t)
B.fP=A.b(s([121,24,80,195,26,62,44,64,85]),t.t)
B.h_=A.b(s([144,71,10,38,171,213,144,34,26]),t.t)
B.ha=A.b(s([170,46,55,19,136,160,33,206,71]),t.t)
B.hl=A.b(s([63,20,8,114,114,208,12,9,226]),t.t)
B.hw=A.b(s([81,40,11,96,182,84,29,16,36]),t.t)
B.eR=A.b(s([B.cB,B.fr,B.fs,B.ft,B.fE,B.fP,B.h_,B.ha,B.hl,B.hw]),t.S)
B.hH=A.b(s([134,183,89,137,98,101,106,165,148]),t.t)
B.hJ=A.b(s([72,187,100,130,157,111,32,75,80]),t.t)
B.fu=A.b(s([66,102,167,99,74,62,40,234,128]),t.t)
B.dR=A.b(s([41,53,9,178,241,141,26,8,107]),t.t)
B.fv=A.b(s([74,43,26,146,73,166,49,23,157]),t.t)
B.fw=A.b(s([65,38,105,160,51,52,31,115,128]),t.t)
B.dg=A.b(s([104,79,12,27,217,255,87,17,7]),t.t)
B.fx=A.b(s([87,68,71,44,114,51,15,186,23]),t.t)
B.fy=A.b(s([47,41,14,110,182,183,21,17,194]),t.t)
B.fz=A.b(s([66,45,25,102,197,189,23,18,22]),t.t)
B.ce=A.b(s([B.hH,B.hJ,B.fu,B.dR,B.fv,B.fw,B.dg,B.fx,B.fy,B.fz]),t.S)
B.fA=A.b(s([88,88,147,150,42,46,45,196,205]),t.t)
B.fB=A.b(s([43,97,183,117,85,38,35,179,61]),t.t)
B.fC=A.b(s([39,53,200,87,26,21,43,232,171]),t.t)
B.fD=A.b(s([56,34,51,104,114,102,29,93,77]),t.t)
B.fF=A.b(s([39,28,85,171,58,165,90,98,64]),t.t)
B.fG=A.b(s([34,22,116,206,23,34,43,166,73]),t.t)
B.fH=A.b(s([107,54,32,26,51,1,81,43,31]),t.t)
B.fI=A.b(s([68,25,106,22,64,171,36,225,114]),t.t)
B.fJ=A.b(s([34,19,21,102,132,188,16,76,124]),t.t)
B.fK=A.b(s([62,18,78,95,85,57,50,48,51]),t.t)
B.bO=A.b(s([B.fA,B.fB,B.fC,B.fD,B.fF,B.fG,B.fH,B.fI,B.fJ,B.fK]),t.S)
B.fL=A.b(s([193,101,35,159,215,111,89,46,111]),t.t)
B.fM=A.b(s([60,148,31,172,219,228,21,18,111]),t.t)
B.dh=A.b(s([112,113,77,85,179,255,38,120,114]),t.t)
B.dS=A.b(s([40,42,1,196,245,209,10,25,109]),t.t)
B.fN=A.b(s([88,43,29,140,166,213,37,43,154]),t.t)
B.fO=A.b(s([61,63,30,155,67,45,68,1,209]),t.t)
B.fQ=A.b(s([100,80,8,43,154,1,51,26,71]),t.t)
B.dT=A.b(s([142,78,78,16,255,128,34,197,171]),t.t)
B.fR=A.b(s([41,40,5,102,211,183,4,1,221]),t.t)
B.fS=A.b(s([51,50,17,168,209,192,23,25,82]),t.t)
B.cc=A.b(s([B.fL,B.fM,B.dh,B.dS,B.fN,B.fO,B.fQ,B.dT,B.fR,B.fS]),t.S)
B.dU=A.b(s([138,31,36,171,27,166,38,44,229]),t.t)
B.fT=A.b(s([67,87,58,169,82,115,26,59,179]),t.t)
B.fU=A.b(s([63,59,90,180,59,166,93,73,154]),t.t)
B.fV=A.b(s([40,40,21,116,143,209,34,39,175]),t.t)
B.fW=A.b(s([47,15,16,183,34,223,49,45,183]),t.t)
B.fX=A.b(s([46,17,33,183,6,98,15,32,183]),t.t)
B.fY=A.b(s([57,46,22,24,128,1,54,17,37]),t.t)
B.fZ=A.b(s([65,32,73,115,28,128,23,128,205]),t.t)
B.h0=A.b(s([40,3,9,115,51,192,18,6,223]),t.t)
B.h1=A.b(s([87,37,9,115,59,77,64,21,47]),t.t)
B.f6=A.b(s([B.dU,B.fT,B.fU,B.fV,B.fW,B.fX,B.fY,B.fZ,B.h0,B.h1]),t.S)
B.h2=A.b(s([104,55,44,218,9,54,53,130,226]),t.t)
B.h3=A.b(s([64,90,70,205,40,41,23,26,57]),t.t)
B.h4=A.b(s([54,57,112,184,5,41,38,166,213]),t.t)
B.h5=A.b(s([30,34,26,133,152,116,10,32,134]),t.t)
B.dV=A.b(s([39,19,53,221,26,114,32,73,255]),t.t)
B.h6=A.b(s([31,9,65,234,2,15,1,118,73]),t.t)
B.di=A.b(s([75,32,12,51,192,255,160,43,51]),t.t)
B.h7=A.b(s([88,31,35,67,102,85,55,186,85]),t.t)
B.h8=A.b(s([56,21,23,111,59,205,45,37,192]),t.t)
B.h9=A.b(s([55,38,70,124,73,102,1,34,98]),t.t)
B.b8=A.b(s([B.h2,B.h3,B.h4,B.h5,B.dV,B.h6,B.di,B.h7,B.h8,B.h9]),t.S)
B.hb=A.b(s([125,98,42,88,104,85,117,175,82]),t.t)
B.hc=A.b(s([95,84,53,89,128,100,113,101,45]),t.t)
B.hd=A.b(s([75,79,123,47,51,128,81,171,1]),t.t)
B.he=A.b(s([57,17,5,71,102,57,53,41,49]),t.t)
B.hf=A.b(s([38,33,13,121,57,73,26,1,85]),t.t)
B.hg=A.b(s([41,10,67,138,77,110,90,47,114]),t.t)
B.dj=A.b(s([115,21,2,10,102,255,166,23,6]),t.t)
B.hh=A.b(s([101,29,16,10,85,128,101,196,26]),t.t)
B.hi=A.b(s([57,18,10,102,102,213,34,20,43]),t.t)
B.hj=A.b(s([117,20,15,36,163,128,68,1,26]),t.t)
B.cS=A.b(s([B.hb,B.hc,B.hd,B.he,B.hf,B.hg,B.dj,B.hh,B.hi,B.hj]),t.S)
B.dA=A.b(s([102,61,71,37,34,53,31,243,192]),t.t)
B.hk=A.b(s([69,60,71,38,73,119,28,222,37]),t.t)
B.dB=A.b(s([68,45,128,34,1,47,11,245,171]),t.t)
B.hm=A.b(s([62,17,19,70,146,85,55,62,70]),t.t)
B.hn=A.b(s([37,43,37,154,100,163,85,160,1]),t.t)
B.ho=A.b(s([63,9,92,136,28,64,32,201,85]),t.t)
B.dk=A.b(s([75,15,9,9,64,255,184,119,16]),t.t)
B.dl=A.b(s([86,6,28,5,64,255,25,248,1]),t.t)
B.dm=A.b(s([56,8,17,132,137,255,55,116,128]),t.t)
B.hp=A.b(s([58,15,20,82,135,57,26,121,40]),t.t)
B.bB=A.b(s([B.dA,B.hk,B.dB,B.hm,B.hn,B.ho,B.dk,B.dl,B.dm,B.hp]),t.S)
B.hq=A.b(s([164,50,31,137,154,133,25,35,218]),t.t)
B.hr=A.b(s([51,103,44,131,131,123,31,6,158]),t.t)
B.hs=A.b(s([86,40,64,135,148,224,45,183,128]),t.t)
B.ht=A.b(s([22,26,17,131,240,154,14,1,209]),t.t)
B.hu=A.b(s([45,16,21,91,64,222,7,1,197]),t.t)
B.hv=A.b(s([56,21,39,155,60,138,23,102,213]),t.t)
B.dn=A.b(s([83,12,13,54,192,255,68,47,28]),t.t)
B.hx=A.b(s([85,26,85,85,128,128,32,146,171]),t.t)
B.hy=A.b(s([18,11,7,63,144,171,4,4,246]),t.t)
B.hz=A.b(s([35,27,10,146,174,171,12,26,128]),t.t)
B.cT=A.b(s([B.hq,B.hr,B.hs,B.ht,B.hu,B.hv,B.dn,B.hx,B.hy,B.hz]),t.S)
B.hA=A.b(s([190,80,35,99,180,80,126,54,45]),t.t)
B.hB=A.b(s([85,126,47,87,176,51,41,20,32]),t.t)
B.hC=A.b(s([101,75,128,139,118,146,116,128,85]),t.t)
B.hD=A.b(s([56,41,15,176,236,85,37,9,62]),t.t)
B.dp=A.b(s([71,30,17,119,118,255,17,18,138]),t.t)
B.hE=A.b(s([101,38,60,138,55,70,43,26,142]),t.t)
B.dq=A.b(s([146,36,19,30,171,255,97,27,20]),t.t)
B.hF=A.b(s([138,45,61,62,219,1,81,188,64]),t.t)
B.hG=A.b(s([32,41,20,117,151,142,20,21,163]),t.t)
B.hI=A.b(s([112,19,12,61,195,128,48,4,24]),t.t)
B.cu=A.b(s([B.hA,B.hB,B.hC,B.hD,B.dp,B.hE,B.dq,B.hF,B.hG,B.hI]),t.S)
B.ad=A.b(s([B.eR,B.ce,B.bO,B.cc,B.f6,B.b8,B.cS,B.bB,B.cT,B.cu]),t.o)
B.A=A.b(s([3226,6412,200,168,38,38,134,134,100,100,100,100,68,68,68,68]),t.t)
B.bE=A.b(s([8,8,4,2]),t.t)
B.ae=A.b(s([A.qo(),A.qE(),A.qH(),A.qy(),A.qq(),A.qp(),A.qr()]),t.B)
B.T=A.b(s([4,5,6,7,8,9,10,10,11,12,13,14,15,16,17,17,18,19,20,20,21,21,22,22,23,23,24,25,25,26,27,28,29,30,31,32,33,34,35,36,37,37,38,39,40,41,42,43,44,45,46,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,76,77,78,79,80,81,82,83,84,85,86,87,88,89,91,93,95,96,98,100,101,102,104,106,108,110,112,114,116,118,122,124,126,128,130,132,134,136,138,140,143,145,148,151,154,157]),t.t)
B.C=A.b(s([7,6,6,5,5,5,5,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0]),t.t)
B.B=A.b(s([80,88,23,71,30,30,62,62,4,4,4,4,4,4,4,4,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41]),t.t)
B.af=A.b(s([0,1,2,3,17,4,5,33,49,6,18,65,81,7,97,113,19,34,50,129,8,20,66,145,161,177,193,9,35,51,82,240,21,98,114,209,10,22,36,52,225,37,241,23,24,25,26,38,39,40,41,42,53,54,55,56,57,58,67,68,69,70,71,72,73,74,83,84,85,86,87,88,89,90,99,100,101,102,103,104,105,106,115,116,117,118,119,120,121,122,130,131,132,133,134,135,136,137,138,146,147,148,149,150,151,152,153,154,162,163,164,165,166,167,168,169,170,178,179,180,181,182,183,184,185,186,194,195,196,197,198,199,200,201,202,210,211,212,213,214,215,216,217,218,226,227,228,229,230,231,232,233,234,242,243,244,245,246,247,248,249,250]),t.t)
B.ag=A.b(s([24,7,23,25,40,6,39,41,22,26,38,42,56,5,55,57,21,27,54,58,37,43,72,4,71,73,20,28,53,59,70,74,36,44,88,69,75,52,60,3,87,89,19,29,86,90,35,45,68,76,85,91,51,61,104,2,103,105,18,30,102,106,34,46,84,92,67,77,101,107,50,62,120,1,119,121,83,93,17,31,100,108,66,78,118,122,33,47,117,123,49,63,99,109,82,94,0,116,124,65,79,16,32,98,110,48,115,125,81,95,64,114,126,97,111,80,113,127,96,112]),t.t)
B.m=A.b(s([0,1,8,16,9,2,3,10,17,24,32,25,18,11,4,5,12,19,26,33,40,48,41,34,27,20,13,6,7,14,21,28,35,42,49,56,57,50,43,36,29,22,15,23,30,37,44,51,58,59,52,45,38,31,39,46,53,60,61,54,47,55,62,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63]),t.t)
B.U=A.b(s([4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,119,122,125,128,131,134,137,140,143,146,149,152,155,158,161,164,167,170,173,177,181,185,189,193,197,201,205,209,213,217,221,225,229,234,239,245,249,254,259,264,269,274,279,284]),t.t)
B.D=A.b(s([0,1,2,3,4,4,5,5,6,6,6,6,7,7,7,7,8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,0,0,16,17,18,18,19,19,20,20,20,20,21,21,21,21,22,22,22,22,22,22,22,22,23,23,23,23,23,23,23,23,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29]),t.t)
B.k=A.b(s([0,1996959894,3993919788,2567524794,124634137,1886057615,3915621685,2657392035,249268274,2044508324,3772115230,2547177864,162941995,2125561021,3887607047,2428444049,498536548,1789927666,4089016648,2227061214,450548861,1843258603,4107580753,2211677639,325883990,1684777152,4251122042,2321926636,335633487,1661365465,4195302755,2366115317,997073096,1281953886,3579855332,2724688242,1006888145,1258607687,3524101629,2768942443,901097722,1119000684,3686517206,2898065728,853044451,1172266101,3705015759,2882616665,651767980,1373503546,3369554304,3218104598,565507253,1454621731,3485111705,3099436303,671266974,1594198024,3322730930,2970347812,795835527,1483230225,3244367275,3060149565,1994146192,31158534,2563907772,4023717930,1907459465,112637215,2680153253,3904427059,2013776290,251722036,2517215374,3775830040,2137656763,141376813,2439277719,3865271297,1802195444,476864866,2238001368,4066508878,1812370925,453092731,2181625025,4111451223,1706088902,314042704,2344532202,4240017532,1658658271,366619977,2362670323,4224994405,1303535960,984961486,2747007092,3569037538,1256170817,1037604311,2765210733,3554079995,1131014506,879679996,2909243462,3663771856,1141124467,855842277,2852801631,3708648649,1342533948,654459306,3188396048,3373015174,1466479909,544179635,3110523913,3462522015,1591671054,702138776,2966460450,3352799412,1504918807,783551873,3082640443,3233442989,3988292384,2596254646,62317068,1957810842,3939845945,2647816111,81470997,1943803523,3814918930,2489596804,225274430,2053790376,3826175755,2466906013,167816743,2097651377,4027552580,2265490386,503444072,1762050814,4150417245,2154129355,426522225,1852507879,4275313526,2312317920,282753626,1742555852,4189708143,2394877945,397917763,1622183637,3604390888,2714866558,953729732,1340076626,3518719985,2797360999,1068828381,1219638859,3624741850,2936675148,906185462,1090812512,3747672003,2825379669,829329135,1181335161,3412177804,3160834842,628085408,1382605366,3423369109,3138078467,570562233,1426400815,3317316542,2998733608,733239954,1555261956,3268935591,3050360625,752459403,1541320221,2607071920,3965973030,1969922972,40735498,2617837225,3943577151,1913087877,83908371,2512341634,3803740692,2075208622,213261112,2463272603,3855990285,2094854071,198958881,2262029012,4057260610,1759359992,534414190,2176718541,4139329115,1873836001,414664567,2282248934,4279200368,1711684554,285281116,2405801727,4167216745,1634467795,376229701,2685067896,3608007406,1308918612,956543938,2808555105,3495958263,1231636301,1047427035,2932959818,3654703836,1088359270,936918e3,2847714899,3736837829,1202900863,817233897,3183342108,3401237130,1404277552,615818150,3134207493,3453421203,1423857449,601450431,3009837614,3294710456,1567103746,711928724,3020668471,3272380065,1510334235,755167117]),t.t)
B.v=A.b(s([0,1,3,7,15,31,63,127,255,511,1023,2047,4095,8191,16383,32767,65535,131071,262143,524287,1048575,2097151,4194303,8388607,16777215,33554431,67108863,134217727,268435455,536870911,1073741823,2147483647,4294967295]),t.t)
B.ah=A.b(s([0,0,1,5,1,1,1,1,1,1,0,0,0,0,0,0,0]),t.t)
B.ak=A.b(s([0,0,2,1,2,4,4,3,4,7,5,4,4,0,1,2,119]),t.t)
B.aj=A.b(s([0,0,2,1,3,3,2,4,3,5,5,4,4,0,0,1,125]),t.t)
B.ai=A.b(s([0,0,3,1,1,1,1,1,1,1,1,1,0,0,0,0,0]),t.t)
B.E=A.b(s([0,1,2,3,6,4,5,6,6,6,6,6,6,6,6,7,0]),t.t)
B.al=A.b(s([1,2,3,0,4,17,5,18,33,49,65,6,19,81,97,7,34,113,20,50,129,145,161,8,35,66,177,193,21,82,209,240,36,51,98,114,130,9,10,22,23,24,25,26,37,38,39,40,41,42,52,53,54,55,56,57,58,67,68,69,70,71,72,73,74,83,84,85,86,87,88,89,90,99,100,101,102,103,104,105,106,115,116,117,118,119,120,121,122,131,132,133,134,135,136,137,138,146,147,148,149,150,151,152,153,154,162,163,164,165,166,167,168,169,170,178,179,180,181,182,183,184,185,186,194,195,196,197,198,199,200,201,202,210,211,212,213,214,215,216,217,218,225,226,227,228,229,230,231,232,233,234,241,242,243,244,245,246,247,248,249,250]),t.t)
B.am=A.b(s([null,A.r_(),A.r0(),A.qZ()]),A.b1("p<~(e,e,e,e,e,bj)?>"))
B.an=A.b(s([1,1.387039845,1.306562965,1.175875602,1,0.785694958,0.5411961,0.275899379]),A.b1("p<y>"))
B.l=A.b(s([28679,28679,31752,-32759,-31735,-30711,-29687,-28663,29703,29703,30727,30727,-27639,-26615,-25591,-24567]),t.t)
B.i=A.b(s([255,255,255,255,255,255,255,255,255,255,255]),t.t)
B.p=A.b(s([B.i,B.i,B.i]),t.S)
B.e8=A.b(s([176,246,255,255,255,255,255,255,255,255,255]),t.t)
B.cC=A.b(s([223,241,252,255,255,255,255,255,255,255,255]),t.t)
B.ei=A.b(s([249,253,253,255,255,255,255,255,255,255,255]),t.t)
B.bV=A.b(s([B.e8,B.cC,B.ei]),t.S)
B.e4=A.b(s([255,244,252,255,255,255,255,255,255,255,255]),t.t)
B.ey=A.b(s([234,254,254,255,255,255,255,255,255,255,255]),t.t)
B.aC=A.b(s([253,255,255,255,255,255,255,255,255,255,255]),t.t)
B.dv=A.b(s([B.e4,B.ey,B.aC]),t.S)
B.e5=A.b(s([255,246,254,255,255,255,255,255,255,255,255]),t.t)
B.f8=A.b(s([239,253,254,255,255,255,255,255,255,255,255]),t.t)
B.aq=A.b(s([254,255,254,255,255,255,255,255,255,255,255]),t.t)
B.cp=A.b(s([B.e5,B.f8,B.aq]),t.S)
B.aA=A.b(s([255,248,254,255,255,255,255,255,255,255,255]),t.t)
B.f9=A.b(s([251,255,254,255,255,255,255,255,255,255,255]),t.t)
B.hK=A.b(s([B.aA,B.f9,B.i]),t.S)
B.Z=A.b(s([255,253,254,255,255,255,255,255,255,255,255]),t.t)
B.e6=A.b(s([251,254,254,255,255,255,255,255,255,255,255]),t.t)
B.bJ=A.b(s([B.Z,B.e6,B.aq]),t.S)
B.dt=A.b(s([255,254,253,255,254,255,255,255,255,255,255]),t.t)
B.f3=A.b(s([250,255,254,255,254,255,255,255,255,255,255]),t.t)
B.F=A.b(s([254,255,255,255,255,255,255,255,255,255,255]),t.t)
B.by=A.b(s([B.dt,B.f3,B.F]),t.S)
B.f2=A.b(s([B.p,B.bV,B.dv,B.cp,B.hK,B.bJ,B.by,B.p]),t.o)
B.ci=A.b(s([217,255,255,255,255,255,255,255,255,255,255]),t.t)
B.e1=A.b(s([225,252,241,253,255,255,254,255,255,255,255]),t.t)
B.f1=A.b(s([234,250,241,250,253,255,253,254,255,255,255]),t.t)
B.bW=A.b(s([B.ci,B.e1,B.f1]),t.S)
B.V=A.b(s([255,254,255,255,255,255,255,255,255,255,255]),t.t)
B.ez=A.b(s([223,254,254,255,255,255,255,255,255,255,255]),t.t)
B.b9=A.b(s([238,253,254,254,255,255,255,255,255,255,255]),t.t)
B.cA=A.b(s([B.V,B.ez,B.b9]),t.S)
B.bX=A.b(s([249,254,255,255,255,255,255,255,255,255,255]),t.t)
B.f7=A.b(s([B.aA,B.bX,B.i]),t.S)
B.ej=A.b(s([255,253,255,255,255,255,255,255,255,255,255]),t.t)
B.bY=A.b(s([247,254,255,255,255,255,255,255,255,255,255]),t.t)
B.c2=A.b(s([B.ej,B.bY,B.i]),t.S)
B.cj=A.b(s([252,255,255,255,255,255,255,255,255,255,255]),t.t)
B.en=A.b(s([B.Z,B.cj,B.i]),t.S)
B.aB=A.b(s([255,254,254,255,255,255,255,255,255,255,255]),t.t)
B.ee=A.b(s([B.aB,B.aC,B.i]),t.S)
B.bZ=A.b(s([255,254,253,255,255,255,255,255,255,255,255]),t.t)
B.ao=A.b(s([250,255,255,255,255,255,255,255,255,255,255]),t.t)
B.bl=A.b(s([B.bZ,B.ao,B.F]),t.S)
B.bN=A.b(s([B.bW,B.cA,B.f7,B.c2,B.en,B.ee,B.bl,B.p]),t.o)
B.cD=A.b(s([186,251,250,255,255,255,255,255,255,255,255]),t.t)
B.ba=A.b(s([234,251,244,254,255,255,255,255,255,255,255]),t.t)
B.cb=A.b(s([251,251,243,253,254,255,254,255,255,255,255]),t.t)
B.f0=A.b(s([B.cD,B.ba,B.cb]),t.S)
B.cE=A.b(s([236,253,254,255,255,255,255,255,255,255,255]),t.t)
B.bG=A.b(s([251,253,253,254,254,255,255,255,255,255,255]),t.t)
B.dr=A.b(s([B.Z,B.cE,B.bG]),t.S)
B.eA=A.b(s([254,254,254,255,255,255,255,255,255,255,255]),t.t)
B.dw=A.b(s([B.aB,B.eA,B.i]),t.S)
B.e9=A.b(s([254,254,255,255,255,255,255,255,255,255,255]),t.t)
B.cs=A.b(s([B.V,B.e9,B.F]),t.S)
B.aJ=A.b(s([B.i,B.F,B.i]),t.S)
B.ct=A.b(s([B.f0,B.dr,B.dw,B.cs,B.aJ,B.p,B.p,B.p]),t.o)
B.ck=A.b(s([248,255,255,255,255,255,255,255,255,255,255]),t.t)
B.bI=A.b(s([250,254,252,254,255,255,255,255,255,255,255]),t.t)
B.ea=A.b(s([248,254,249,253,255,255,255,255,255,255,255]),t.t)
B.dz=A.b(s([B.ck,B.bI,B.ea]),t.S)
B.ek=A.b(s([255,253,253,255,255,255,255,255,255,255,255]),t.t)
B.cl=A.b(s([246,253,253,255,255,255,255,255,255,255,255]),t.t)
B.bb=A.b(s([252,254,251,254,254,255,255,255,255,255,255]),t.t)
B.bc=A.b(s([B.ek,B.cl,B.bb]),t.S)
B.e7=A.b(s([255,254,252,255,255,255,255,255,255,255,255]),t.t)
B.eb=A.b(s([248,254,253,255,255,255,255,255,255,255,255]),t.t)
B.e2=A.b(s([253,255,254,254,255,255,255,255,255,255,255]),t.t)
B.bL=A.b(s([B.e7,B.eb,B.e2]),t.S)
B.fa=A.b(s([255,251,254,255,255,255,255,255,255,255,255]),t.t)
B.fb=A.b(s([245,251,254,255,255,255,255,255,255,255,255]),t.t)
B.fc=A.b(s([253,253,254,255,255,255,255,255,255,255,255]),t.t)
B.eS=A.b(s([B.fa,B.fb,B.fc]),t.S)
B.el=A.b(s([255,251,253,255,255,255,255,255,255,255,255]),t.t)
B.cF=A.b(s([252,253,254,255,255,255,255,255,255,255,255]),t.t)
B.eU=A.b(s([B.el,B.cF,B.V]),t.S)
B.c_=A.b(s([255,252,255,255,255,255,255,255,255,255,255]),t.t)
B.fd=A.b(s([249,255,254,255,255,255,255,255,255,255,255]),t.t)
B.fe=A.b(s([255,255,254,255,255,255,255,255,255,255,255]),t.t)
B.bz=A.b(s([B.c_,B.fd,B.fe]),t.S)
B.em=A.b(s([255,255,253,255,255,255,255,255,255,255,255]),t.t)
B.hL=A.b(s([B.em,B.ao,B.i]),t.S)
B.bC=A.b(s([B.dz,B.bc,B.bL,B.eS,B.eU,B.bz,B.hL,B.aJ]),t.o)
B.cf=A.b(s([B.f2,B.bN,B.ct,B.bC]),t.hc)
B.W=A.b(s([0,1,2,3,4,5,6,7,8,8,9,9,10,10,11,11,12,12,12,12,13,13,13,13,14,14,14,14,15,15,15,15,16,16,16,16,16,16,16,16,17,17,17,17,17,17,17,17,18,18,18,18,18,18,18,18,19,19,19,19,19,19,19,19,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,28]),t.t)
B.ap=A.b(s([0,1,3,7,15,31,63,127,255,511,1023,2047,4095]),t.t)
B.S=A.b(s([128,128,128,128,128,128,128,128,128,128,128]),t.t)
B.aw=A.b(s([B.S,B.S,B.S]),t.S)
B.d3=A.b(s([253,136,254,255,228,219,128,128,128,128,128]),t.t)
B.cV=A.b(s([189,129,242,255,227,213,255,219,128,128,128]),t.t)
B.fn=A.b(s([106,126,227,252,214,209,255,255,128,128,128]),t.t)
B.fm=A.b(s([B.d3,B.cV,B.fn]),t.S)
B.c4=A.b(s([1,98,248,255,236,226,255,255,128,128,128]),t.t)
B.d9=A.b(s([181,133,238,254,221,234,255,154,128,128,128]),t.t)
B.cW=A.b(s([78,134,202,247,198,180,255,219,128,128,128]),t.t)
B.dE=A.b(s([B.c4,B.d9,B.cW]),t.S)
B.cg=A.b(s([1,185,249,255,243,255,128,128,128,128,128]),t.t)
B.dF=A.b(s([184,150,247,255,236,224,128,128,128,128,128]),t.t)
B.bQ=A.b(s([77,110,216,255,236,230,128,128,128,128,128]),t.t)
B.cJ=A.b(s([B.cg,B.dF,B.bQ]),t.S)
B.ch=A.b(s([1,101,251,255,241,255,128,128,128,128,128]),t.t)
B.ff=A.b(s([170,139,241,252,236,209,255,255,128,128,128]),t.t)
B.cN=A.b(s([37,116,196,243,228,255,255,255,128,128,128]),t.t)
B.c0=A.b(s([B.ch,B.ff,B.cN]),t.S)
B.bk=A.b(s([1,204,254,255,245,255,128,128,128,128,128]),t.t)
B.bR=A.b(s([207,160,250,255,238,128,128,128,128,128,128]),t.t)
B.dG=A.b(s([102,103,231,255,211,171,128,128,128,128,128]),t.t)
B.bA=A.b(s([B.bk,B.bR,B.dG]),t.S)
B.eX=A.b(s([1,152,252,255,240,255,128,128,128,128,128]),t.t)
B.dH=A.b(s([177,135,243,255,234,225,128,128,128,128,128]),t.t)
B.bS=A.b(s([80,129,211,255,194,224,128,128,128,128,128]),t.t)
B.bD=A.b(s([B.eX,B.dH,B.bS]),t.S)
B.ab=A.b(s([1,1,255,128,128,128,128,128,128,128,128]),t.t)
B.bo=A.b(s([246,1,255,128,128,128,128,128,128,128,128]),t.t)
B.bf=A.b(s([255,128,128,128,128,128,128,128,128,128,128]),t.t)
B.cz=A.b(s([B.ab,B.bo,B.bf]),t.S)
B.bm=A.b(s([B.aw,B.fm,B.dE,B.cJ,B.c0,B.bA,B.bD,B.cz]),t.o)
B.bp=A.b(s([198,35,237,223,193,187,162,160,145,155,62]),t.t)
B.bn=A.b(s([131,45,198,221,172,176,220,157,252,221,1]),t.t)
B.dL=A.b(s([68,47,146,208,149,167,221,162,255,223,128]),t.t)
B.bK=A.b(s([B.bp,B.bn,B.dL]),t.S)
B.eo=A.b(s([1,149,241,255,221,224,255,255,128,128,128]),t.t)
B.cX=A.b(s([184,141,234,253,222,220,255,199,128,128,128]),t.t)
B.dW=A.b(s([81,99,181,242,176,190,249,202,255,255,128]),t.t)
B.c1=A.b(s([B.eo,B.cX,B.dW]),t.S)
B.ef=A.b(s([1,129,232,253,214,197,242,196,255,255,128]),t.t)
B.da=A.b(s([99,121,210,250,201,198,255,202,128,128,128]),t.t)
B.dX=A.b(s([23,91,163,242,170,187,247,210,255,255,128]),t.t)
B.hM=A.b(s([B.ef,B.da,B.dX]),t.S)
B.eY=A.b(s([1,200,246,255,234,255,128,128,128,128,128]),t.t)
B.cO=A.b(s([109,178,241,255,231,245,255,255,128,128,128]),t.t)
B.c5=A.b(s([44,130,201,253,205,192,255,255,128,128,128]),t.t)
B.cr=A.b(s([B.eY,B.cO,B.c5]),t.S)
B.ec=A.b(s([1,132,239,251,219,209,255,165,128,128,128]),t.t)
B.c6=A.b(s([94,136,225,251,218,190,255,255,128,128,128]),t.t)
B.cY=A.b(s([22,100,174,245,186,161,255,199,128,128,128]),t.t)
B.dD=A.b(s([B.ec,B.c6,B.cY]),t.S)
B.fi=A.b(s([1,182,249,255,232,235,128,128,128,128,128]),t.t)
B.dI=A.b(s([124,143,241,255,227,234,128,128,128,128,128]),t.t)
B.cZ=A.b(s([35,77,181,251,193,211,255,205,128,128,128]),t.t)
B.ex=A.b(s([B.fi,B.dI,B.cZ]),t.S)
B.cI=A.b(s([1,157,247,255,236,231,255,255,128,128,128]),t.t)
B.ep=A.b(s([121,141,235,255,225,227,255,255,128,128,128]),t.t)
B.d_=A.b(s([45,99,188,251,195,217,255,224,128,128,128]),t.t)
B.bH=A.b(s([B.cI,B.ep,B.d_]),t.S)
B.fj=A.b(s([1,1,251,255,213,255,128,128,128,128,128]),t.t)
B.d4=A.b(s([203,1,248,255,255,128,128,128,128,128,128]),t.t)
B.eZ=A.b(s([137,1,177,255,224,255,128,128,128,128,128]),t.t)
B.cG=A.b(s([B.fj,B.d4,B.eZ]),t.S)
B.c3=A.b(s([B.bK,B.c1,B.hM,B.cr,B.dD,B.ex,B.bH,B.cG]),t.o)
B.eh=A.b(s([253,9,248,251,207,208,255,192,128,128,128]),t.t)
B.dx=A.b(s([175,13,224,243,193,185,249,198,255,255,128]),t.t)
B.dM=A.b(s([73,17,171,221,161,179,236,167,255,234,128]),t.t)
B.bd=A.b(s([B.eh,B.dx,B.dM]),t.S)
B.eq=A.b(s([1,95,247,253,212,183,255,255,128,128,128]),t.t)
B.et=A.b(s([239,90,244,250,211,209,255,255,128,128,128]),t.t)
B.fo=A.b(s([155,77,195,248,188,195,255,255,128,128,128]),t.t)
B.cv=A.b(s([B.eq,B.et,B.fo]),t.S)
B.ed=A.b(s([1,24,239,251,218,219,255,205,128,128,128]),t.t)
B.bT=A.b(s([201,51,219,255,196,186,128,128,128,128,128]),t.t)
B.d0=A.b(s([69,46,190,239,201,218,255,228,128,128,128]),t.t)
B.dy=A.b(s([B.ed,B.bT,B.d0]),t.S)
B.bF=A.b(s([1,191,251,255,255,128,128,128,128,128,128]),t.t)
B.fk=A.b(s([223,165,249,255,213,255,128,128,128,128,128]),t.t)
B.d5=A.b(s([141,124,248,255,255,128,128,128,128,128,128]),t.t)
B.bP=A.b(s([B.bF,B.fk,B.d5]),t.S)
B.d6=A.b(s([1,16,248,255,255,128,128,128,128,128,128]),t.t)
B.f_=A.b(s([190,36,230,255,236,255,128,128,128,128,128]),t.t)
B.bq=A.b(s([149,1,255,128,128,128,128,128,128,128,128]),t.t)
B.cK=A.b(s([B.d6,B.f_,B.bq]),t.S)
B.br=A.b(s([1,226,255,128,128,128,128,128,128,128,128]),t.t)
B.cd=A.b(s([247,192,255,128,128,128,128,128,128,128,128]),t.t)
B.bs=A.b(s([240,128,255,128,128,128,128,128,128,128,128]),t.t)
B.fg=A.b(s([B.br,B.cd,B.bs]),t.S)
B.d7=A.b(s([1,134,252,255,255,128,128,128,128,128,128]),t.t)
B.d8=A.b(s([213,62,250,255,255,128,128,128,128,128,128]),t.t)
B.bt=A.b(s([55,93,255,128,128,128,128,128,128,128,128]),t.t)
B.cn=A.b(s([B.d7,B.d8,B.bt]),t.S)
B.cm=A.b(s([B.bd,B.cv,B.dy,B.bP,B.cK,B.fg,B.cn,B.aw]),t.o)
B.cR=A.b(s([202,24,213,235,186,191,220,160,240,175,255]),t.t)
B.dN=A.b(s([126,38,182,232,169,184,228,174,255,187,128]),t.t)
B.dO=A.b(s([61,46,138,219,151,178,240,170,255,216,128]),t.t)
B.fh=A.b(s([B.cR,B.dN,B.dO]),t.S)
B.dY=A.b(s([1,112,230,250,199,191,247,159,255,255,128]),t.t)
B.db=A.b(s([166,109,228,252,211,215,255,174,128,128,128]),t.t)
B.dZ=A.b(s([39,77,162,232,172,180,245,178,255,255,128]),t.t)
B.cH=A.b(s([B.dY,B.db,B.dZ]),t.S)
B.e_=A.b(s([1,52,220,246,198,199,249,220,255,255,128]),t.t)
B.eg=A.b(s([124,74,191,243,183,193,250,221,255,255,128]),t.t)
B.e0=A.b(s([24,71,130,219,154,170,243,182,255,255,128]),t.t)
B.dC=A.b(s([B.e_,B.eg,B.e0]),t.S)
B.d1=A.b(s([1,182,225,249,219,240,255,224,128,128,128]),t.t)
B.dc=A.b(s([149,150,226,252,216,205,255,171,128,128,128]),t.t)
B.cM=A.b(s([28,108,170,242,183,194,254,223,255,255,128]),t.t)
B.co=A.b(s([B.d1,B.dc,B.cM]),t.S)
B.dd=A.b(s([1,81,230,252,204,203,255,192,128,128,128]),t.t)
B.c7=A.b(s([123,102,209,247,188,196,255,233,128,128,128]),t.t)
B.d2=A.b(s([20,95,153,243,164,173,255,203,128,128,128]),t.t)
B.bM=A.b(s([B.dd,B.c7,B.d2]),t.S)
B.bU=A.b(s([1,222,248,255,216,213,128,128,128,128,128]),t.t)
B.ca=A.b(s([168,175,246,252,235,205,255,255,128,128,128]),t.t)
B.c8=A.b(s([47,116,215,255,211,212,255,255,128,128,128]),t.t)
B.cy=A.b(s([B.bU,B.ca,B.c8]),t.S)
B.c9=A.b(s([1,121,236,253,212,214,255,255,128,128,128]),t.t)
B.de=A.b(s([141,84,213,252,201,202,255,219,128,128,128]),t.t)
B.df=A.b(s([42,80,160,240,162,185,255,205,128,128,128]),t.t)
B.fl=A.b(s([B.c9,B.de,B.df]),t.S)
B.bu=A.b(s([244,1,255,128,128,128,128,128,128,128,128]),t.t)
B.bv=A.b(s([238,1,255,128,128,128,128,128,128,128,128]),t.t)
B.cq=A.b(s([B.ab,B.bu,B.bv]),t.S)
B.eT=A.b(s([B.fh,B.cH,B.dC,B.co,B.bM,B.cy,B.fl,B.cq]),t.o)
B.cw=A.b(s([B.bm,B.c3,B.cm,B.eT]),t.hc)
B.G=A.b(s([0,1,2,3,4,5,6,7,8,9,10,11]),t.t)
B.H=A.b(s([6430,6400,6400,6400,3225,3225,3225,3225,944,944,944,944,976,976,976,976,1456,1456,1456,1456,1488,1488,1488,1488,718,718,718,718,718,718,718,718,750,750,750,750,750,750,750,750,1520,1520,1520,1520,1552,1552,1552,1552,428,428,428,428,428,428,428,428,428,428,428,428,428,428,428,428,654,654,654,654,654,654,654,654,1072,1072,1072,1072,1104,1104,1104,1104,1136,1136,1136,1136,1168,1168,1168,1168,1200,1200,1200,1200,1232,1232,1232,1232,622,622,622,622,622,622,622,622,1008,1008,1008,1008,1040,1040,1040,1040,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,396,396,396,396,396,396,396,396,396,396,396,396,396,396,396,396,1712,1712,1712,1712,1744,1744,1744,1744,846,846,846,846,846,846,846,846,1264,1264,1264,1264,1296,1296,1296,1296,1328,1328,1328,1328,1360,1360,1360,1360,1392,1392,1392,1392,1424,1424,1424,1424,686,686,686,686,686,686,686,686,910,910,910,910,910,910,910,910,1968,1968,1968,1968,2000,2000,2000,2000,2032,2032,2032,2032,16,16,16,16,10257,10257,10257,10257,12305,12305,12305,12305,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,330,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,362,878,878,878,878,878,878,878,878,1904,1904,1904,1904,1936,1936,1936,1936,-18413,-18413,-16365,-16365,-14317,-14317,-10221,-10221,590,590,590,590,590,590,590,590,782,782,782,782,782,782,782,782,1584,1584,1584,1584,1616,1616,1616,1616,1648,1648,1648,1648,1680,1680,1680,1680,814,814,814,814,814,814,814,814,1776,1776,1776,1776,1808,1808,1808,1808,1840,1840,1840,1840,1872,1872,1872,1872,6157,6157,6157,6157,6157,6157,6157,6157,6157,6157,6157,6157,6157,6157,6157,6157,-12275,-12275,-12275,-12275,-12275,-12275,-12275,-12275,-12275,-12275,-12275,-12275,-12275,-12275,-12275,-12275,14353,14353,14353,14353,16401,16401,16401,16401,22547,22547,24595,24595,20497,20497,20497,20497,18449,18449,18449,18449,26643,26643,28691,28691,30739,30739,-32749,-32749,-30701,-30701,-28653,-28653,-26605,-26605,-24557,-24557,-22509,-22509,-20461,-20461,8207,8207,8207,8207,8207,8207,8207,8207,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,104,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,4107,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,266,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,298,524,524,524,524,524,524,524,524,524,524,524,524,524,524,524,524,556,556,556,556,556,556,556,556,556,556,556,556,556,556,556,556,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,168,460,460,460,460,460,460,460,460,460,460,460,460,460,460,460,460,492,492,492,492,492,492,492,492,492,492,492,492,492,492,492,492,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,2059,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232,232]),t.t)
B.q=A.b(s([0,-128,64,-64,32,-96,96,-32,16,-112,80,-48,48,-80,112,-16,8,-120,72,-56,40,-88,104,-24,24,-104,88,-40,56,-72,120,-8,4,-124,68,-60,36,-92,100,-28,20,-108,84,-44,52,-76,116,-12,12,-116,76,-52,44,-84,108,-20,28,-100,92,-36,60,-68,124,-4,2,-126,66,-62,34,-94,98,-30,18,-110,82,-46,50,-78,114,-14,10,-118,74,-54,42,-86,106,-22,26,-102,90,-38,58,-70,122,-6,6,-122,70,-58,38,-90,102,-26,22,-106,86,-42,54,-74,118,-10,14,-114,78,-50,46,-82,110,-18,30,-98,94,-34,62,-66,126,-2,1,-127,65,-63,33,-95,97,-31,17,-111,81,-47,49,-79,113,-15,9,-119,73,-55,41,-87,105,-23,25,-103,89,-39,57,-71,121,-7,5,-123,69,-59,37,-91,101,-27,21,-107,85,-43,53,-75,117,-11,13,-115,77,-51,45,-83,109,-19,29,-99,93,-35,61,-67,125,-3,3,-125,67,-61,35,-93,99,-29,19,-109,83,-45,51,-77,115,-13,11,-117,75,-53,43,-85,107,-21,27,-101,91,-37,59,-69,123,-5,7,-121,71,-57,39,-89,103,-25,23,-105,87,-41,55,-73,119,-9,15,-113,79,-49,47,-81,111,-17,31,-97,95,-33,63,-65,127,-1]),t.t)
B.w=A.b(s([0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13]),t.t)
B.cL=A.b(s([0,1,2,3,4,6,8,12,16,24,32,48,64,96,128,192,256,384,512,768,1024,1536,2048,3072,4096,6144,8192,12288,16384,24576]),t.t)
B.ar=A.b(s([5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5]),t.t)
B.I=A.b(s([12,8,140,8,76,8,204,8,44,8,172,8,108,8,236,8,28,8,156,8,92,8,220,8,60,8,188,8,124,8,252,8,2,8,130,8,66,8,194,8,34,8,162,8,98,8,226,8,18,8,146,8,82,8,210,8,50,8,178,8,114,8,242,8,10,8,138,8,74,8,202,8,42,8,170,8,106,8,234,8,26,8,154,8,90,8,218,8,58,8,186,8,122,8,250,8,6,8,134,8,70,8,198,8,38,8,166,8,102,8,230,8,22,8,150,8,86,8,214,8,54,8,182,8,118,8,246,8,14,8,142,8,78,8,206,8,46,8,174,8,110,8,238,8,30,8,158,8,94,8,222,8,62,8,190,8,126,8,254,8,1,8,129,8,65,8,193,8,33,8,161,8,97,8,225,8,17,8,145,8,81,8,209,8,49,8,177,8,113,8,241,8,9,8,137,8,73,8,201,8,41,8,169,8,105,8,233,8,25,8,153,8,89,8,217,8,57,8,185,8,121,8,249,8,5,8,133,8,69,8,197,8,37,8,165,8,101,8,229,8,21,8,149,8,85,8,213,8,53,8,181,8,117,8,245,8,13,8,141,8,77,8,205,8,45,8,173,8,109,8,237,8,29,8,157,8,93,8,221,8,61,8,189,8,125,8,253,8,19,9,275,9,147,9,403,9,83,9,339,9,211,9,467,9,51,9,307,9,179,9,435,9,115,9,371,9,243,9,499,9,11,9,267,9,139,9,395,9,75,9,331,9,203,9,459,9,43,9,299,9,171,9,427,9,107,9,363,9,235,9,491,9,27,9,283,9,155,9,411,9,91,9,347,9,219,9,475,9,59,9,315,9,187,9,443,9,123,9,379,9,251,9,507,9,7,9,263,9,135,9,391,9,71,9,327,9,199,9,455,9,39,9,295,9,167,9,423,9,103,9,359,9,231,9,487,9,23,9,279,9,151,9,407,9,87,9,343,9,215,9,471,9,55,9,311,9,183,9,439,9,119,9,375,9,247,9,503,9,15,9,271,9,143,9,399,9,79,9,335,9,207,9,463,9,47,9,303,9,175,9,431,9,111,9,367,9,239,9,495,9,31,9,287,9,159,9,415,9,95,9,351,9,223,9,479,9,63,9,319,9,191,9,447,9,127,9,383,9,255,9,511,9,0,7,64,7,32,7,96,7,16,7,80,7,48,7,112,7,8,7,72,7,40,7,104,7,24,7,88,7,56,7,120,7,4,7,68,7,36,7,100,7,20,7,84,7,52,7,116,7,3,8,131,8,67,8,195,8,35,8,163,8,99,8,227,8]),t.t)
B.R=A.b(s([0,0,0]),t.a)
B.cP=A.b(s([B.R,B.R,B.R]),t.U)
B.eB=A.b(s([0.375,1,0]),t.a)
B.eC=A.b(s([0.375,0,1]),t.a)
B.eD=A.b(s([0.25,1,1]),t.a)
B.cQ=A.b(s([B.eB,B.eC,B.eD]),t.U)
B.eJ=A.b(s([0.4375,1,0]),t.a)
B.eu=A.b(s([0.1875,-1,1]),t.a)
B.eK=A.b(s([0.3125,0,1]),t.a)
B.eL=A.b(s([0.0625,1,1]),t.a)
B.dJ=A.b(s([B.eJ,B.eu,B.eK,B.eL]),t.U)
B.eM=A.b(s([0.19047619047619047,1,0]),t.a)
B.eN=A.b(s([0.09523809523809523,2,0]),t.a)
B.e3=A.b(s([0.047619047619047616,-2,1]),t.a)
B.ev=A.b(s([0.09523809523809523,-1,1]),t.a)
B.eO=A.b(s([0.19047619047619047,0,1]),t.a)
B.eP=A.b(s([0.09523809523809523,1,1]),t.a)
B.bi=A.b(s([0.047619047619047616,2,1]),t.a)
B.dK=A.b(s([0.023809523809523808,-2,2]),t.a)
B.cx=A.b(s([0.047619047619047616,-1,2]),t.a)
B.eQ=A.b(s([0.09523809523809523,0,2]),t.a)
B.bj=A.b(s([0.047619047619047616,1,2]),t.a)
B.cU=A.b(s([0.023809523809523808,2,2]),t.a)
B.f5=A.b(s([B.eM,B.eN,B.e3,B.ev,B.eO,B.eP,B.bi,B.dK,B.cx,B.eQ,B.bj,B.cU]),t.U)
B.eE=A.b(s([0.125,1,0]),t.a)
B.eF=A.b(s([0.125,2,0]),t.a)
B.ew=A.b(s([0.125,-1,1]),t.a)
B.eG=A.b(s([0.125,0,1]),t.a)
B.eH=A.b(s([0.125,1,1]),t.a)
B.eI=A.b(s([0.125,0,2]),t.a)
B.es=A.b(s([B.eE,B.eF,B.ew,B.eG,B.eH,B.eI]),t.U)
B.as=A.b(s([B.cP,B.cQ,B.dJ,B.f5,B.es]),A.b1("p<h<h<E>>>"))
B.J=A.b(s([-0.0,1,-1,2,-2,3,4,6,-3,5,-4,-5,-6,7,-7,8,-8,-9]),t.t)
B.au=A.b(s([0,1,4,8,5,2,3,6,9,12,13,10,7,11,14,15]),t.t)
B.at=A.b(s([0,4,8,12,128,132,136,140,256,260,264,268,384,388,392,396]),t.t)
B.X=A.b(s([0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15]),t.t)
B.ds=A.b(s([0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0,0,0]),t.t)
B.du=A.b(s([]),t.s)
B.av=A.b(s([]),t.dG)
B.ax=A.b(s([1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577]),t.t)
B.ay=A.b(s([0,5,16,5,8,5,24,5,4,5,20,5,12,5,28,5,2,5,18,5,10,5,26,5,6,5,22,5,14,5,30,5,1,5,17,5,9,5,25,5,5,5,21,5,13,5,29,5,3,5,19,5,11,5,27,5,7,5,23,5]),t.t)
B.x=A.b(s([0,1,5,6,14,15,27,28,2,4,7,13,16,26,29,42,3,8,12,17,25,30,41,43,9,11,18,24,31,40,44,53,10,19,23,32,39,45,52,54,20,22,33,38,46,51,55,60,21,34,37,47,50,56,59,61,35,36,48,49,57,58,62,63]),t.t)
B.dP=A.b(s([16,11,10,16,24,40,51,61,12,12,14,19,26,58,60,55,14,13,16,24,40,57,69,56,14,17,22,29,51,87,80,62,18,22,37,56,68,109,103,77,24,35,55,64,81,104,113,92,49,64,78,87,103,121,120,101,72,92,95,98,112,100,103,99]),t.t)
B.dQ=A.b(s([17,18,24,47,99,99,99,99,18,21,26,66,99,99,99,99,24,26,56,99,99,99,99,99,47,66,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99]),t.t)
B.j=A.b(s([0,1,3,7,15,31,63,127,255]),t.t)
B.r=A.b(s([0,128,192,224,240,248,252,254,255]),t.t)
B.az=A.b(s([0,1,1,2,4,8,1,1,2,4,8,4,8]),t.t)
B.K=A.b(s([62,62,30,30,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,3225,588,588,588,588,588,588,588,588,1680,1680,20499,22547,24595,26643,1776,1776,1808,1808,-24557,-22509,-20461,-18413,1904,1904,1936,1936,-16365,-14317,782,782,782,782,814,814,814,814,-12269,-10221,10257,10257,12305,12305,14353,14353,16403,18451,1712,1712,1744,1744,28691,30739,-32749,-30701,-28653,-26605,2061,2061,2061,2061,2061,2061,2061,2061,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,424,750,750,750,750,1616,1616,1648,1648,1424,1424,1456,1456,1488,1488,1520,1520,1840,1840,1872,1872,1968,1968,8209,8209,524,524,524,524,524,524,524,524,556,556,556,556,556,556,556,556,1552,1552,1584,1584,2000,2000,2032,2032,976,976,1008,1008,1040,1040,1072,1072,1296,1296,1328,1328,718,718,718,718,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,456,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,326,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,358,490,490,490,490,490,490,490,490,490,490,490,490,490,490,490,490,4113,4113,6161,6161,848,848,880,880,912,912,944,944,622,622,622,622,654,654,654,654,1104,1104,1136,1136,1168,1168,1200,1200,1232,1232,1264,1264,686,686,686,686,1360,1360,1392,1392,12,12,12,12,12,12,12,12,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390,390]),t.t)
B.L=A.b(s([0,0,27858,1023,65534,51199,65535,32767]),t.t)
B.Y=A.b(s([0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0]),t.t)
B.er=A.b(s([0,1,2,3,4,5,6,7,8,10,12,14,16,20,24,28,32,40,48,56,64,80,96,112,128,160,192,224,0]),t.t)
B.aD=A.b(s([3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,35,43,51,59,67,83,99,115,131,163,195,227,258]),t.t)
B.bg=A.b(s([173,148,140]),t.t)
B.bh=A.b(s([176,155,140,135]),t.t)
B.fq=A.b(s([180,157,141,134,130]),t.t)
B.bw=A.b(s([254,254,243,230,196,177,153,140,133,130,129]),t.t)
B.aE=A.b(s([B.bg,B.bh,B.fq,B.bw]),t.S)
B.aF=A.b(s([A.qs(),A.qF(),A.qI(),A.qz(),A.qD(),A.qL(),A.qC(),A.qK(),A.qx(),A.qB()]),t.B)
B.aG=A.b(s([0,1,3,7,15,31,63,127,255,511,1023,2047,4095,8191,16383,32767,65535]),t.t)
B.eV=A.b(s([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,3,7]),t.t)
B.M=A.b(s([16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15]),t.t)
B.eW=A.b(s([17,18,0,1,2,3,4,5,16,6,7,8,9,10,11,12,13,14,15]),t.t)
B.aH=A.b(s([127,127,191,127,159,191,223,127,143,159,175,191,207,223,239,127,135,143,151,159,167,175,183,191,199,207,215,223,231,239,247,127,131,135,139,143,147,151,155,159,163,167,171,175,179,183,187,191,195,199,203,207,211,215,219,223,227,231,235,239,243,247,251,127,129,131,133,135,137,139,141,143,145,147,149,151,153,155,157,159,161,163,165,167,169,171,173,175,177,179,181,183,185,187,189,191,193,195,197,199,201,203,205,207,209,211,213,215,217,219,221,223,225,227,229,231,233,235,237,239,241,243,245,247,249,251,253,127]),t.t)
B.fp=A.b(s([280,256,256,256,40]),t.t)
B.aI=A.b(s([0,1,1,2,4,8,1,1,2,4,8,4,8,0]),t.t)
B.aK=new A.cC([315,"artist",258,"bitsPerSample",265,"cellLength",264,"cellWidth",320,"colorMap",259,"compression",306,"dateTime",34665,"exifIFD",338,"extraSamples",266,"fillOrder",289,"freeByteCounts",288,"freeOffsets",291,"grayResponseCurve",290,"grayResponseUnit",316,"hostComputer",34675,"iccProfile",270,"imageDescription",257,"imageLength",256,"imageWidth",33723,"iptc",271,"make",281,"maxSampleValue",280,"minSampleValue",272,"model",254,"newSubfileType",274,"orientation",262,"photometricInterpretation",34377,"photoshop",284,"planarConfiguration",317,"predictor",296,"resolutionUnit",278,"rowsPerStrip",277,"samplesPerPixel",305,"software",279,"stripByteCounts",273,"stropOffsets",255,"subfileType",292,"t4Options",293,"t6Options",263,"thresholding",322,"tileWidth",323,"tileLength",324,"tileOffsets",325,"tileByteCounts",700,"xmp",282,"xResolution",283,"yResolution",529,"yCbCrCoefficients",530,"yCbCrSubsampling",531,"yCbCrPositioning",339,"sampleFormat"],A.b1("cC<e,m>"))
B.f4=A.b(s(["123","3dml","3ds","3g2","3gp","7z","aab","aac","aam","aas","abw","ac","acc","ace","acu","acutc","adp","aep","afm","afp","ahead","ai","aif","aifc","aiff","air","ait","ami","apk","appcache","application","apr","arc","asc","asf","asm","aso","asx","atc","atom","atomcat","atomsvc","atx","au","avi","avif","aw","azf","azs","azw","bat","bcpio","bdf","bdm","bed","bh2","bin","blb","blorb","bmi","bmp","book","box","boz","bpk","btif","bz","bz2","c","c11amc","c11amz","c4d","c4f","c4g","c4p","c4u","cab","caf","cap","car","cat","cb7","cba","cbr","cbt","cbz","cc","cct","ccxml","cdbcmsg","cdf","cdkey","cdmia","cdmic","cdmid","cdmio","cdmiq","cdx","cdxml","cdy","cer","cfs","cgm","chat","chm","chrt","cif","cii","cil","cla","class","clkk","clkp","clkt","clkw","clkx","clp","cmc","cmdf","cml","cmp","cmx","cod","com","conf","cpio","cpp","cpt","crd","crl","crt","cryptonote","csh","csml","csp","css","cst","csv","cu","curl","cww","cxt","cxx","dae","daf","dart","dataless","davmount","dbk","dcr","dcurl","dd2","ddd","deb","def","deploy","der","dfac","dgc","dic","dir","dis","dist","distz","djv","djvu","dll","dmg","dmp","dms","dna","doc","docm","docx","dot","dotm","dotx","dp","dpg","dra","dsc","dssc","dtb","dtd","dts","dtshd","dump","dvb","dvi","dwf","dwg","dxf","dxp","dxr","ecelp4800","ecelp7470","ecelp9600","ecma","edm","edx","efif","ei6","elc","emf","eml","emma","emz","eol","eot","eps","epub","es3","esa","esf","et3","etx","eva","evy","exe","exi","ext","ez","ez2","ez3","f","f4v","f77","f90","fbs","fcdt","fcs","fdf","fe_launch","fg5","fgd","fh","fh4","fh5","fh7","fhc","fig","flac","fli","flo","flv","flw","flx","fly","fm","fnc","for","fpx","frame","fsc","fst","ftc","fti","fvt","fxp","fxpl","fzs","g2w","g3","g3w","gac","gam","gbr","gca","gdl","geo","gex","ggb","ggt","ghf","gif","gim","glb","gltf","gml","gmx","gnumeric","gph","gpx","gqf","gqs","gram","gramps","gre","grv","grxml","gsf","gtar","gtm","gtw","gv","gxf","gxt","h","h261","h263","h264","hal","hbci","hdf","heic","heif","hh","hlp","hpgl","hpid","hps","hqx","htke","htm","html","hvd","hvp","hvs","i2g","icc","ice","icm","ico","ics","ief","ifb","ifm","iges","igl","igm","igs","igx","iif","imp","ims","in","ink","inkml","install","iota","ipfix","ipk","irm","irp","iso","itp","ivp","ivu","jad","jam","jar","java","jisp","jlt","jnlp","joda","jpe","jpeg","jpg","jpgm","jpgv","jpm","js","json","jsonml","kar","karbon","kfo","kia","kml","kmz","kne","knp","kon","kpr","kpt","kpxx","ksp","ktr","ktx","ktz","kwd","kwt","lasxml","latex","lbd","lbe","les","lha","link66","list","list3820","listafp","lnk","log","lostxml","lrf","lrm","ltf","lvp","lwp","lzh","m13","m14","m1v","m21","m2a","m2v","m3a","m3u","m3u8","m4a","m4u","m4v","ma","mads","mag","maker","man","mar","mathml","mb","mbk","mbox","mc1","mcd","mcurl","mdb","mdi","me","mesh","meta4","metalink","mets","mfm","mft","mgp","mgz","mid","midi","mie","mif","mime","mj2","mjp2","mk3d","mka","mks","mkv","mlp","mmd","mmf","mmr","mng","mny","mobi","mods","mov","movie","mp2","mp21","mp2a","mp3","mp4","mp4a","mp4s","mp4v","mpc","mpe","mpeg","mpg","mpg4","mpga","mpkg","mpm","mpn","mpp","mpt","mpy","mqy","mrc","mrcx","ms","mscml","mseed","mseq","msf","msh","msi","msl","msty","mts","mus","musicxml","mvb","mwf","mxf","mxl","mxml","mxs","mxu","n-gage","n3","nb","nbp","nc","ncx","nfo","ngdat","nitf","nlu","nml","nnd","nns","nnw","npx","nsc","nsf","ntf","nzb","oa2","oa3","oas","obd","obj","oda","odb","odc","odf","odft","odg","odi","odm","odp","ods","odt","oga","ogg","ogv","ogx","omdoc","onepkg","onetmp","onetoc","onetoc2","opf","opml","oprc","org","osf","osfpvg","otc","otf","otg","oth","oti","otp","ots","ott","oxps","oxt","p","p10","p12","p7b","p7c","p7m","p7r","p7s","p8","pas","paw","pbd","pbm","pcap","pcf","pcl","pclxl","pct","pcurl","pcx","pdb","pdf","pfa","pfb","pfm","pfr","pfx","pgm","pgn","pgp","pic","pkg","pki","pkipath","plb","plc","plf","pls","pml","png","pnm","portpkg","pot","potm","potx","ppam","ppd","ppm","pps","ppsm","ppsx","ppt","pptm","pptx","pqa","prc","pre","prf","ps","psb","psd","psf","pskcxml","ptid","pub","pvb","pwn","pya","pyv","qam","qbo","qfx","qps","qt","qwd","qwt","qxb","qxd","qxl","qxt","ra","ram","rar","ras","rcprofile","rdf","rdz","rep","res","rgb","rif","rip","ris","rl","rlc","rld","rm","rmi","rmp","rms","rmvb","rnc","roa","roff","rp9","rpss","rpst","rq","rs","rsd","rss","rtf","rtx","s","s3m","saf","sbml","sc","scd","scm","scq","scs","scurl","sda","sdc","sdd","sdkd","sdkm","sdp","sdw","see","seed","sema","semd","semf","ser","setpay","setreg","sfd-hdstx","sfs","sfv","sgi","sgl","sgm","sgml","sh","shar","shf","sid","sig","sil","silo","sis","sisx","sit","sitx","skd","skm","skp","skt","sldm","sldx","slt","sm","smf","smi","smil","smv","smzip","snd","snf","so","spc","spf","spl","spot","spp","spq","spx","sql","src","srt","sru","srx","ssdl","sse","ssf","ssml","st","stc","std","stf","sti","stk","stl","str","stw","sub","sus","susp","sv4cpio","sv4crc","svc","svd","svg","svgz","swa","swf","swi","sxc","sxd","sxg","sxi","sxm","sxw","t","t3","taglet","tao","tar","tcap","tcl","teacher","tei","teicorpus","tex","texi","texinfo","text","tfi","tfm","tga","thmx","tif","tiff","tmo","toml","torrent","tpl","tpt","tr","tra","trm","tsd","tsv","ttc","ttf","ttl","twd","twds","txd","txf","txt","u32","udeb","ufd","ufdl","ulx","umj","unityweb","uoml","uri","uris","urls","ustar","utz","uu","uva","uvd","uvf","uvg","uvh","uvi","uvm","uvp","uvs","uvt","uvu","uvv","uvva","uvvd","uvvf","uvvg","uvvh","uvvi","uvvm","uvvp","uvvs","uvvt","uvvu","uvvv","uvvx","uvvz","uvx","uvz","vcard","vcd","vcf","vcg","vcs","vcx","vis","viv","vob","vor","vox","vrml","vsd","vsf","vss","vst","vsw","vtu","vxml","w3d","wad","wasm","wav","wax","wbmp","wbs","wbxml","wcm","wdb","wdp","weba","webm","webmanifest","webp","wg","wgt","wks","wm","wma","wmd","wmf","wml","wmlc","wmls","wmlsc","wmv","wmx","wmz","woff","woff2","wpd","wpl","wps","wqd","wri","wrl","wsdl","wspolicy","wtb","wvx","x32","x3d","x3db","x3dbz","x3dv","x3dvz","x3dz","xaml","xap","xar","xbap","xbd","xbm","xdf","xdm","xdp","xdssc","xdw","xenc","xer","xfdf","xfdl","xht","xhtml","xhvml","xif","xla","xlam","xlc","xlf","xlm","xls","xlsb","xlsm","xlsx","xlt","xltm","xltx","xlw","xm","xml","xo","xop","xpi","xpl","xpm","xpr","xps","xpw","xpx","xsl","xslt","xsm","xspf","xul","xvm","xvml","xwd","xyz","xz","yang","yin","z1","z2","z3","z4","z5","z6","z7","z8","zaz","zip","zir","zirz","zmm"]),t.s)
B.hN=new A.ct(991,{"123":"application/vnd.lotus-1-2-3","3dml":"text/vnd.in3d.3dml","3ds":"image/x-3ds","3g2":"video/3gpp2","3gp":"video/3gpp","7z":"application/x-7z-compressed",aab:"application/x-authorware-bin",aac:"audio/aac",aam:"application/x-authorware-map",aas:"application/x-authorware-seg",abw:"application/x-abiword",ac:"application/pkix-attr-cert",acc:"application/vnd.americandynamics.acc",ace:"application/x-ace-compressed",acu:"application/vnd.acucobol",acutc:"application/vnd.acucorp",adp:"audio/adpcm",aep:"application/vnd.audiograph",afm:"application/x-font-type1",afp:"application/vnd.ibm.modcap",ahead:"application/vnd.ahead.space",ai:"application/postscript",aif:"audio/x-aiff",aifc:"audio/x-aiff",aiff:"audio/x-aiff",air:"application/vnd.adobe.air-application-installer-package+zip",ait:"application/vnd.dvb.ait",ami:"application/vnd.amiga.ami",apk:"application/vnd.android.package-archive",appcache:"text/cache-manifest",application:"application/x-ms-application",apr:"application/vnd.lotus-approach",arc:"application/x-freearc",asc:"application/pgp-signature",asf:"video/x-ms-asf",asm:"text/x-asm",aso:"application/vnd.accpac.simply.aso",asx:"video/x-ms-asf",atc:"application/vnd.acucorp",atom:"application/atom+xml",atomcat:"application/atomcat+xml",atomsvc:"application/atomsvc+xml",atx:"application/vnd.antix.game-component",au:"audio/basic",avi:"video/x-msvideo",avif:"image/avif",aw:"application/applixware",azf:"application/vnd.airzip.filesecure.azf",azs:"application/vnd.airzip.filesecure.azs",azw:"application/vnd.amazon.ebook",bat:"application/x-msdownload",bcpio:"application/x-bcpio",bdf:"application/x-font-bdf",bdm:"application/vnd.syncml.dm+wbxml",bed:"application/vnd.realvnc.bed",bh2:"application/vnd.fujitsu.oasysprs",bin:"application/octet-stream",blb:"application/x-blorb",blorb:"application/x-blorb",bmi:"application/vnd.bmi",bmp:"image/bmp",book:"application/vnd.framemaker",box:"application/vnd.previewsystems.box",boz:"application/x-bzip2",bpk:"application/octet-stream",btif:"image/prs.btif",bz:"application/x-bzip",bz2:"application/x-bzip2",c:"text/x-c",c11amc:"application/vnd.cluetrust.cartomobile-config",c11amz:"application/vnd.cluetrust.cartomobile-config-pkg",c4d:"application/vnd.clonk.c4group",c4f:"application/vnd.clonk.c4group",c4g:"application/vnd.clonk.c4group",c4p:"application/vnd.clonk.c4group",c4u:"application/vnd.clonk.c4group",cab:"application/vnd.ms-cab-compressed",caf:"audio/x-caf",cap:"application/vnd.tcpdump.pcap",car:"application/vnd.curl.car",cat:"application/vnd.ms-pki.seccat",cb7:"application/x-cbr",cba:"application/x-cbr",cbr:"application/x-cbr",cbt:"application/x-cbr",cbz:"application/x-cbr",cc:"text/x-c",cct:"application/x-director",ccxml:"application/ccxml+xml",cdbcmsg:"application/vnd.contact.cmsg",cdf:"application/x-netcdf",cdkey:"application/vnd.mediastation.cdkey",cdmia:"application/cdmi-capability",cdmic:"application/cdmi-container",cdmid:"application/cdmi-domain",cdmio:"application/cdmi-object",cdmiq:"application/cdmi-queue",cdx:"chemical/x-cdx",cdxml:"application/vnd.chemdraw+xml",cdy:"application/vnd.cinderella",cer:"application/pkix-cert",cfs:"application/x-cfs-compressed",cgm:"image/cgm",chat:"application/x-chat",chm:"application/vnd.ms-htmlhelp",chrt:"application/vnd.kde.kchart",cif:"chemical/x-cif",cii:"application/vnd.anser-web-certificate-issue-initiation",cil:"application/vnd.ms-artgalry",cla:"application/vnd.claymore",class:"application/java-vm",clkk:"application/vnd.crick.clicker.keyboard",clkp:"application/vnd.crick.clicker.palette",clkt:"application/vnd.crick.clicker.template",clkw:"application/vnd.crick.clicker.wordbank",clkx:"application/vnd.crick.clicker",clp:"application/x-msclip",cmc:"application/vnd.cosmocaller",cmdf:"chemical/x-cmdf",cml:"chemical/x-cml",cmp:"application/vnd.yellowriver-custom-menu",cmx:"image/x-cmx",cod:"application/vnd.rim.cod",com:"application/x-msdownload",conf:"text/plain",cpio:"application/x-cpio",cpp:"text/x-c",cpt:"application/mac-compactpro",crd:"application/x-mscardfile",crl:"application/pkix-crl",crt:"application/x-x509-ca-cert",cryptonote:"application/vnd.rig.cryptonote",csh:"application/x-csh",csml:"chemical/x-csml",csp:"application/vnd.commonspace",css:"text/css",cst:"application/x-director",csv:"text/csv",cu:"application/cu-seeme",curl:"text/vnd.curl",cww:"application/prs.cww",cxt:"application/x-director",cxx:"text/x-c",dae:"model/vnd.collada+xml",daf:"application/vnd.mobius.daf",dart:"text/x-dart",dataless:"application/vnd.fdsn.seed",davmount:"application/davmount+xml",dbk:"application/docbook+xml",dcr:"application/x-director",dcurl:"text/vnd.curl.dcurl",dd2:"application/vnd.oma.dd2+xml",ddd:"application/vnd.fujixerox.ddd",deb:"application/x-debian-package",def:"text/plain",deploy:"application/octet-stream",der:"application/x-x509-ca-cert",dfac:"application/vnd.dreamfactory",dgc:"application/x-dgc-compressed",dic:"text/x-c",dir:"application/x-director",dis:"application/vnd.mobius.dis",dist:"application/octet-stream",distz:"application/octet-stream",djv:"image/vnd.djvu",djvu:"image/vnd.djvu",dll:"application/x-msdownload",dmg:"application/x-apple-diskimage",dmp:"application/vnd.tcpdump.pcap",dms:"application/octet-stream",dna:"application/vnd.dna",doc:"application/msword",docm:"application/vnd.ms-word.document.macroenabled.12",docx:"application/vnd.openxmlformats-officedocument.wordprocessingml.document",dot:"application/msword",dotm:"application/vnd.ms-word.template.macroenabled.12",dotx:"application/vnd.openxmlformats-officedocument.wordprocessingml.template",dp:"application/vnd.osgi.dp",dpg:"application/vnd.dpgraph",dra:"audio/vnd.dra",dsc:"text/prs.lines.tag",dssc:"application/dssc+der",dtb:"application/x-dtbook+xml",dtd:"application/xml-dtd",dts:"audio/vnd.dts",dtshd:"audio/vnd.dts.hd",dump:"application/octet-stream",dvb:"video/vnd.dvb.file",dvi:"application/x-dvi",dwf:"model/vnd.dwf",dwg:"image/vnd.dwg",dxf:"image/vnd.dxf",dxp:"application/vnd.spotfire.dxp",dxr:"application/x-director",ecelp4800:"audio/vnd.nuera.ecelp4800",ecelp7470:"audio/vnd.nuera.ecelp7470",ecelp9600:"audio/vnd.nuera.ecelp9600",ecma:"application/ecmascript",edm:"application/vnd.novadigm.edm",edx:"application/vnd.novadigm.edx",efif:"application/vnd.picsel",ei6:"application/vnd.pg.osasli",elc:"application/octet-stream",emf:"application/x-msmetafile",eml:"message/rfc822",emma:"application/emma+xml",emz:"application/x-msmetafile",eol:"audio/vnd.digital-winds",eot:"application/vnd.ms-fontobject",eps:"application/postscript",epub:"application/epub+zip",es3:"application/vnd.eszigno3+xml",esa:"application/vnd.osgi.subsystem",esf:"application/vnd.epson.esf",et3:"application/vnd.eszigno3+xml",etx:"text/x-setext",eva:"application/x-eva",evy:"application/x-envoy",exe:"application/x-msdownload",exi:"application/exi",ext:"application/vnd.novadigm.ext",ez:"application/andrew-inset",ez2:"application/vnd.ezpix-album",ez3:"application/vnd.ezpix-package",f:"text/x-fortran",f4v:"video/x-f4v",f77:"text/x-fortran",f90:"text/x-fortran",fbs:"image/vnd.fastbidsheet",fcdt:"application/vnd.adobe.formscentral.fcdt",fcs:"application/vnd.isac.fcs",fdf:"application/vnd.fdf",fe_launch:"application/vnd.denovo.fcselayout-link",fg5:"application/vnd.fujitsu.oasysgp",fgd:"application/x-director",fh:"image/x-freehand",fh4:"image/x-freehand",fh5:"image/x-freehand",fh7:"image/x-freehand",fhc:"image/x-freehand",fig:"application/x-xfig",flac:"audio/x-flac",fli:"video/x-fli",flo:"application/vnd.micrografx.flo",flv:"video/x-flv",flw:"application/vnd.kde.kivio",flx:"text/vnd.fmi.flexstor",fly:"text/vnd.fly",fm:"application/vnd.framemaker",fnc:"application/vnd.frogans.fnc",for:"text/x-fortran",fpx:"image/vnd.fpx",frame:"application/vnd.framemaker",fsc:"application/vnd.fsc.weblaunch",fst:"image/vnd.fst",ftc:"application/vnd.fluxtime.clip",fti:"application/vnd.anser-web-funds-transfer-initiation",fvt:"video/vnd.fvt",fxp:"application/vnd.adobe.fxp",fxpl:"application/vnd.adobe.fxp",fzs:"application/vnd.fuzzysheet",g2w:"application/vnd.geoplan",g3:"image/g3fax",g3w:"application/vnd.geospace",gac:"application/vnd.groove-account",gam:"application/x-tads",gbr:"application/rpki-ghostbusters",gca:"application/x-gca-compressed",gdl:"model/vnd.gdl",geo:"application/vnd.dynageo",gex:"application/vnd.geometry-explorer",ggb:"application/vnd.geogebra.file",ggt:"application/vnd.geogebra.tool",ghf:"application/vnd.groove-help",gif:"image/gif",gim:"application/vnd.groove-identity-message",glb:"model/gltf-binary",gltf:"model/gltf+json",gml:"application/gml+xml",gmx:"application/vnd.gmx",gnumeric:"application/x-gnumeric",gph:"application/vnd.flographit",gpx:"application/gpx+xml",gqf:"application/vnd.grafeq",gqs:"application/vnd.grafeq",gram:"application/srgs",gramps:"application/x-gramps-xml",gre:"application/vnd.geometry-explorer",grv:"application/vnd.groove-injector",grxml:"application/srgs+xml",gsf:"application/x-font-ghostscript",gtar:"application/x-gtar",gtm:"application/vnd.groove-tool-message",gtw:"model/vnd.gtw",gv:"text/vnd.graphviz",gxf:"application/gxf",gxt:"application/vnd.geonext",h:"text/x-c",h261:"video/h261",h263:"video/h263",h264:"video/h264",hal:"application/vnd.hal+xml",hbci:"application/vnd.hbci",hdf:"application/x-hdf",heic:"image/heic",heif:"image/heif",hh:"text/x-c",hlp:"application/winhlp",hpgl:"application/vnd.hp-hpgl",hpid:"application/vnd.hp-hpid",hps:"application/vnd.hp-hps",hqx:"application/mac-binhex40",htke:"application/vnd.kenameaapp",htm:"text/html",html:"text/html",hvd:"application/vnd.yamaha.hv-dic",hvp:"application/vnd.yamaha.hv-voice",hvs:"application/vnd.yamaha.hv-script",i2g:"application/vnd.intergeo",icc:"application/vnd.iccprofile",ice:"x-conference/x-cooltalk",icm:"application/vnd.iccprofile",ico:"image/x-icon",ics:"text/calendar",ief:"image/ief",ifb:"text/calendar",ifm:"application/vnd.shana.informed.formdata",iges:"model/iges",igl:"application/vnd.igloader",igm:"application/vnd.insors.igm",igs:"model/iges",igx:"application/vnd.micrografx.igx",iif:"application/vnd.shana.informed.interchange",imp:"application/vnd.accpac.simply.imp",ims:"application/vnd.ms-ims",in:"text/plain",ink:"application/inkml+xml",inkml:"application/inkml+xml",install:"application/x-install-instructions",iota:"application/vnd.astraea-software.iota",ipfix:"application/ipfix",ipk:"application/vnd.shana.informed.package",irm:"application/vnd.ibm.rights-management",irp:"application/vnd.irepository.package+xml",iso:"application/x-iso9660-image",itp:"application/vnd.shana.informed.formtemplate",ivp:"application/vnd.immervision-ivp",ivu:"application/vnd.immervision-ivu",jad:"text/vnd.sun.j2me.app-descriptor",jam:"application/vnd.jam",jar:"application/java-archive",java:"text/x-java-source",jisp:"application/vnd.jisp",jlt:"application/vnd.hp-jlyt",jnlp:"application/x-java-jnlp-file",joda:"application/vnd.joost.joda-archive",jpe:"image/jpeg",jpeg:"image/jpeg",jpg:"image/jpeg",jpgm:"video/jpm",jpgv:"video/jpeg",jpm:"video/jpm",js:"application/javascript",json:"application/json",jsonml:"application/jsonml+json",kar:"audio/midi",karbon:"application/vnd.kde.karbon",kfo:"application/vnd.kde.kformula",kia:"application/vnd.kidspiration",kml:"application/vnd.google-earth.kml+xml",kmz:"application/vnd.google-earth.kmz",kne:"application/vnd.kinar",knp:"application/vnd.kinar",kon:"application/vnd.kde.kontour",kpr:"application/vnd.kde.kpresenter",kpt:"application/vnd.kde.kpresenter",kpxx:"application/vnd.ds-keypoint",ksp:"application/vnd.kde.kspread",ktr:"application/vnd.kahootz",ktx:"image/ktx",ktz:"application/vnd.kahootz",kwd:"application/vnd.kde.kword",kwt:"application/vnd.kde.kword",lasxml:"application/vnd.las.las+xml",latex:"application/x-latex",lbd:"application/vnd.llamagraphics.life-balance.desktop",lbe:"application/vnd.llamagraphics.life-balance.exchange+xml",les:"application/vnd.hhe.lesson-player",lha:"application/x-lzh-compressed",link66:"application/vnd.route66.link66+xml",list:"text/plain",list3820:"application/vnd.ibm.modcap",listafp:"application/vnd.ibm.modcap",lnk:"application/x-ms-shortcut",log:"text/plain",lostxml:"application/lost+xml",lrf:"application/octet-stream",lrm:"application/vnd.ms-lrm",ltf:"application/vnd.frogans.ltf",lvp:"audio/vnd.lucent.voice",lwp:"application/vnd.lotus-wordpro",lzh:"application/x-lzh-compressed",m13:"application/x-msmediaview",m14:"application/x-msmediaview",m1v:"video/mpeg",m21:"application/mp21",m2a:"audio/mpeg",m2v:"video/mpeg",m3a:"audio/mpeg",m3u:"audio/x-mpegurl",m3u8:"application/vnd.apple.mpegurl",m4a:"audio/mp4",m4u:"video/vnd.mpegurl",m4v:"video/x-m4v",ma:"application/mathematica",mads:"application/mads+xml",mag:"application/vnd.ecowin.chart",maker:"application/vnd.framemaker",man:"text/troff",mar:"application/octet-stream",mathml:"application/mathml+xml",mb:"application/mathematica",mbk:"application/vnd.mobius.mbk",mbox:"application/mbox",mc1:"application/vnd.medcalcdata",mcd:"application/vnd.mcd",mcurl:"text/vnd.curl.mcurl",mdb:"application/x-msaccess",mdi:"image/vnd.ms-modi",me:"text/troff",mesh:"model/mesh",meta4:"application/metalink4+xml",metalink:"application/metalink+xml",mets:"application/mets+xml",mfm:"application/vnd.mfmp",mft:"application/rpki-manifest",mgp:"application/vnd.osgeo.mapguide.package",mgz:"application/vnd.proteus.magazine",mid:"audio/midi",midi:"audio/midi",mie:"application/x-mie",mif:"application/vnd.mif",mime:"message/rfc822",mj2:"video/mj2",mjp2:"video/mj2",mk3d:"video/x-matroska",mka:"audio/x-matroska",mks:"video/x-matroska",mkv:"video/x-matroska",mlp:"application/vnd.dolby.mlp",mmd:"application/vnd.chipnuts.karaoke-mmd",mmf:"application/vnd.smaf",mmr:"image/vnd.fujixerox.edmics-mmr",mng:"video/x-mng",mny:"application/x-msmoney",mobi:"application/x-mobipocket-ebook",mods:"application/mods+xml",mov:"video/quicktime",movie:"video/x-sgi-movie",mp2:"audio/mpeg",mp21:"application/mp21",mp2a:"audio/mpeg",mp3:"audio/mpeg",mp4:"video/mp4",mp4a:"audio/mp4",mp4s:"application/mp4",mp4v:"video/mp4",mpc:"application/vnd.mophun.certificate",mpe:"video/mpeg",mpeg:"video/mpeg",mpg:"video/mpeg",mpg4:"video/mp4",mpga:"audio/mpeg",mpkg:"application/vnd.apple.installer+xml",mpm:"application/vnd.blueice.multipass",mpn:"application/vnd.mophun.application",mpp:"application/vnd.ms-project",mpt:"application/vnd.ms-project",mpy:"application/vnd.ibm.minipay",mqy:"application/vnd.mobius.mqy",mrc:"application/marc",mrcx:"application/marcxml+xml",ms:"text/troff",mscml:"application/mediaservercontrol+xml",mseed:"application/vnd.fdsn.mseed",mseq:"application/vnd.mseq",msf:"application/vnd.epson.msf",msh:"model/mesh",msi:"application/x-msdownload",msl:"application/vnd.mobius.msl",msty:"application/vnd.muvee.style",mts:"model/vnd.mts",mus:"application/vnd.musician",musicxml:"application/vnd.recordare.musicxml+xml",mvb:"application/x-msmediaview",mwf:"application/vnd.mfer",mxf:"application/mxf",mxl:"application/vnd.recordare.musicxml",mxml:"application/xv+xml",mxs:"application/vnd.triscape.mxs",mxu:"video/vnd.mpegurl","n-gage":"application/vnd.nokia.n-gage.symbian.install",n3:"text/n3",nb:"application/mathematica",nbp:"application/vnd.wolfram.player",nc:"application/x-netcdf",ncx:"application/x-dtbncx+xml",nfo:"text/x-nfo",ngdat:"application/vnd.nokia.n-gage.data",nitf:"application/vnd.nitf",nlu:"application/vnd.neurolanguage.nlu",nml:"application/vnd.enliven",nnd:"application/vnd.noblenet-directory",nns:"application/vnd.noblenet-sealer",nnw:"application/vnd.noblenet-web",npx:"image/vnd.net-fpx",nsc:"application/x-conference",nsf:"application/vnd.lotus-notes",ntf:"application/vnd.nitf",nzb:"application/x-nzb",oa2:"application/vnd.fujitsu.oasys2",oa3:"application/vnd.fujitsu.oasys3",oas:"application/vnd.fujitsu.oasys",obd:"application/x-msbinder",obj:"application/x-tgif",oda:"application/oda",odb:"application/vnd.oasis.opendocument.database",odc:"application/vnd.oasis.opendocument.chart",odf:"application/vnd.oasis.opendocument.formula",odft:"application/vnd.oasis.opendocument.formula-template",odg:"application/vnd.oasis.opendocument.graphics",odi:"application/vnd.oasis.opendocument.image",odm:"application/vnd.oasis.opendocument.text-master",odp:"application/vnd.oasis.opendocument.presentation",ods:"application/vnd.oasis.opendocument.spreadsheet",odt:"application/vnd.oasis.opendocument.text",oga:"audio/ogg",ogg:"audio/ogg",ogv:"video/ogg",ogx:"application/ogg",omdoc:"application/omdoc+xml",onepkg:"application/onenote",onetmp:"application/onenote",onetoc:"application/onenote",onetoc2:"application/onenote",opf:"application/oebps-package+xml",opml:"text/x-opml",oprc:"application/vnd.palm",org:"application/vnd.lotus-organizer",osf:"application/vnd.yamaha.openscoreformat",osfpvg:"application/vnd.yamaha.openscoreformat.osfpvg+xml",otc:"application/vnd.oasis.opendocument.chart-template",otf:"application/x-font-otf",otg:"application/vnd.oasis.opendocument.graphics-template",oth:"application/vnd.oasis.opendocument.text-web",oti:"application/vnd.oasis.opendocument.image-template",otp:"application/vnd.oasis.opendocument.presentation-template",ots:"application/vnd.oasis.opendocument.spreadsheet-template",ott:"application/vnd.oasis.opendocument.text-template",oxps:"application/oxps",oxt:"application/vnd.openofficeorg.extension",p:"text/x-pascal",p10:"application/pkcs10",p12:"application/x-pkcs12",p7b:"application/x-pkcs7-certificates",p7c:"application/pkcs7-mime",p7m:"application/pkcs7-mime",p7r:"application/x-pkcs7-certreqresp",p7s:"application/pkcs7-signature",p8:"application/pkcs8",pas:"text/x-pascal",paw:"application/vnd.pawaafile",pbd:"application/vnd.powerbuilder6",pbm:"image/x-portable-bitmap",pcap:"application/vnd.tcpdump.pcap",pcf:"application/x-font-pcf",pcl:"application/vnd.hp-pcl",pclxl:"application/vnd.hp-pclxl",pct:"image/x-pict",pcurl:"application/vnd.curl.pcurl",pcx:"image/x-pcx",pdb:"application/vnd.palm",pdf:"application/pdf",pfa:"application/x-font-type1",pfb:"application/x-font-type1",pfm:"application/x-font-type1",pfr:"application/font-tdpfr",pfx:"application/x-pkcs12",pgm:"image/x-portable-graymap",pgn:"application/x-chess-pgn",pgp:"application/pgp-encrypted",pic:"image/x-pict",pkg:"application/octet-stream",pki:"application/pkixcmp",pkipath:"application/pkix-pkipath",plb:"application/vnd.3gpp.pic-bw-large",plc:"application/vnd.mobius.plc",plf:"application/vnd.pocketlearn",pls:"application/pls+xml",pml:"application/vnd.ctc-posml",png:"image/png",pnm:"image/x-portable-anymap",portpkg:"application/vnd.macports.portpkg",pot:"application/vnd.ms-powerpoint",potm:"application/vnd.ms-powerpoint.template.macroenabled.12",potx:"application/vnd.openxmlformats-officedocument.presentationml.template",ppam:"application/vnd.ms-powerpoint.addin.macroenabled.12",ppd:"application/vnd.cups-ppd",ppm:"image/x-portable-pixmap",pps:"application/vnd.ms-powerpoint",ppsm:"application/vnd.ms-powerpoint.slideshow.macroenabled.12",ppsx:"application/vnd.openxmlformats-officedocument.presentationml.slideshow",ppt:"application/vnd.ms-powerpoint",pptm:"application/vnd.ms-powerpoint.presentation.macroenabled.12",pptx:"application/vnd.openxmlformats-officedocument.presentationml.presentation",pqa:"application/vnd.palm",prc:"application/x-mobipocket-ebook",pre:"application/vnd.lotus-freelance",prf:"application/pics-rules",ps:"application/postscript",psb:"application/vnd.3gpp.pic-bw-small",psd:"image/vnd.adobe.photoshop",psf:"application/x-font-linux-psf",pskcxml:"application/pskc+xml",ptid:"application/vnd.pvi.ptid1",pub:"application/x-mspublisher",pvb:"application/vnd.3gpp.pic-bw-var",pwn:"application/vnd.3m.post-it-notes",pya:"audio/vnd.ms-playready.media.pya",pyv:"video/vnd.ms-playready.media.pyv",qam:"application/vnd.epson.quickanime",qbo:"application/vnd.intu.qbo",qfx:"application/vnd.intu.qfx",qps:"application/vnd.publishare-delta-tree",qt:"video/quicktime",qwd:"application/vnd.quark.quarkxpress",qwt:"application/vnd.quark.quarkxpress",qxb:"application/vnd.quark.quarkxpress",qxd:"application/vnd.quark.quarkxpress",qxl:"application/vnd.quark.quarkxpress",qxt:"application/vnd.quark.quarkxpress",ra:"audio/x-pn-realaudio",ram:"audio/x-pn-realaudio",rar:"application/x-rar-compressed",ras:"image/x-cmu-raster",rcprofile:"application/vnd.ipunplugged.rcprofile",rdf:"application/rdf+xml",rdz:"application/vnd.data-vision.rdz",rep:"application/vnd.businessobjects",res:"application/x-dtbresource+xml",rgb:"image/x-rgb",rif:"application/reginfo+xml",rip:"audio/vnd.rip",ris:"application/x-research-info-systems",rl:"application/resource-lists+xml",rlc:"image/vnd.fujixerox.edmics-rlc",rld:"application/resource-lists-diff+xml",rm:"application/vnd.rn-realmedia",rmi:"audio/midi",rmp:"audio/x-pn-realaudio-plugin",rms:"application/vnd.jcp.javame.midlet-rms",rmvb:"application/vnd.rn-realmedia-vbr",rnc:"application/relax-ng-compact-syntax",roa:"application/rpki-roa",roff:"text/troff",rp9:"application/vnd.cloanto.rp9",rpss:"application/vnd.nokia.radio-presets",rpst:"application/vnd.nokia.radio-preset",rq:"application/sparql-query",rs:"application/rls-services+xml",rsd:"application/rsd+xml",rss:"application/rss+xml",rtf:"application/rtf",rtx:"text/richtext",s:"text/x-asm",s3m:"audio/s3m",saf:"application/vnd.yamaha.smaf-audio",sbml:"application/sbml+xml",sc:"application/vnd.ibm.secure-container",scd:"application/x-msschedule",scm:"application/vnd.lotus-screencam",scq:"application/scvp-cv-request",scs:"application/scvp-cv-response",scurl:"text/vnd.curl.scurl",sda:"application/vnd.stardivision.draw",sdc:"application/vnd.stardivision.calc",sdd:"application/vnd.stardivision.impress",sdkd:"application/vnd.solent.sdkm+xml",sdkm:"application/vnd.solent.sdkm+xml",sdp:"application/sdp",sdw:"application/vnd.stardivision.writer",see:"application/vnd.seemail",seed:"application/vnd.fdsn.seed",sema:"application/vnd.sema",semd:"application/vnd.semd",semf:"application/vnd.semf",ser:"application/java-serialized-object",setpay:"application/set-payment-initiation",setreg:"application/set-registration-initiation","sfd-hdstx":"application/vnd.hydrostatix.sof-data",sfs:"application/vnd.spotfire.sfs",sfv:"text/x-sfv",sgi:"image/sgi",sgl:"application/vnd.stardivision.writer-global",sgm:"text/sgml",sgml:"text/sgml",sh:"application/x-sh",shar:"application/x-shar",shf:"application/shf+xml",sid:"image/x-mrsid-image",sig:"application/pgp-signature",sil:"audio/silk",silo:"model/mesh",sis:"application/vnd.symbian.install",sisx:"application/vnd.symbian.install",sit:"application/x-stuffit",sitx:"application/x-stuffitx",skd:"application/vnd.koan",skm:"application/vnd.koan",skp:"application/vnd.koan",skt:"application/vnd.koan",sldm:"application/vnd.ms-powerpoint.slide.macroenabled.12",sldx:"application/vnd.openxmlformats-officedocument.presentationml.slide",slt:"application/vnd.epson.salt",sm:"application/vnd.stepmania.stepchart",smf:"application/vnd.stardivision.math",smi:"application/smil+xml",smil:"application/smil+xml",smv:"video/x-smv",smzip:"application/vnd.stepmania.package",snd:"audio/basic",snf:"application/x-font-snf",so:"application/octet-stream",spc:"application/x-pkcs7-certificates",spf:"application/vnd.yamaha.smaf-phrase",spl:"application/x-futuresplash",spot:"text/vnd.in3d.spot",spp:"application/scvp-vp-response",spq:"application/scvp-vp-request",spx:"audio/ogg",sql:"application/x-sql",src:"application/x-wais-source",srt:"application/x-subrip",sru:"application/sru+xml",srx:"application/sparql-results+xml",ssdl:"application/ssdl+xml",sse:"application/vnd.kodak-descriptor",ssf:"application/vnd.epson.ssf",ssml:"application/ssml+xml",st:"application/vnd.sailingtracker.track",stc:"application/vnd.sun.xml.calc.template",std:"application/vnd.sun.xml.draw.template",stf:"application/vnd.wt.stf",sti:"application/vnd.sun.xml.impress.template",stk:"application/hyperstudio",stl:"application/vnd.ms-pki.stl",str:"application/vnd.pg.format",stw:"application/vnd.sun.xml.writer.template",sub:"text/vnd.dvb.subtitle",sus:"application/vnd.sus-calendar",susp:"application/vnd.sus-calendar",sv4cpio:"application/x-sv4cpio",sv4crc:"application/x-sv4crc",svc:"application/vnd.dvb.service",svd:"application/vnd.svd",svg:"image/svg+xml",svgz:"image/svg+xml",swa:"application/x-director",swf:"application/x-shockwave-flash",swi:"application/vnd.aristanetworks.swi",sxc:"application/vnd.sun.xml.calc",sxd:"application/vnd.sun.xml.draw",sxg:"application/vnd.sun.xml.writer.global",sxi:"application/vnd.sun.xml.impress",sxm:"application/vnd.sun.xml.math",sxw:"application/vnd.sun.xml.writer",t:"text/troff",t3:"application/x-t3vm-image",taglet:"application/vnd.mynfc",tao:"application/vnd.tao.intent-module-archive",tar:"application/x-tar",tcap:"application/vnd.3gpp2.tcap",tcl:"application/x-tcl",teacher:"application/vnd.smart.teacher",tei:"application/tei+xml",teicorpus:"application/tei+xml",tex:"application/x-tex",texi:"application/x-texinfo",texinfo:"application/x-texinfo",text:"text/plain",tfi:"application/thraud+xml",tfm:"application/x-tex-tfm",tga:"image/x-tga",thmx:"application/vnd.ms-officetheme",tif:"image/tiff",tiff:"image/tiff",tmo:"application/vnd.tmobile-livetv",toml:"application/toml",torrent:"application/x-bittorrent",tpl:"application/vnd.groove-tool-template",tpt:"application/vnd.trid.tpt",tr:"text/troff",tra:"application/vnd.trueapp",trm:"application/x-msterminal",tsd:"application/timestamped-data",tsv:"text/tab-separated-values",ttc:"application/x-font-ttf",ttf:"application/x-font-ttf",ttl:"text/turtle",twd:"application/vnd.simtech-mindmapper",twds:"application/vnd.simtech-mindmapper",txd:"application/vnd.genomatix.tuxedo",txf:"application/vnd.mobius.txf",txt:"text/plain",u32:"application/x-authorware-bin",udeb:"application/x-debian-package",ufd:"application/vnd.ufdl",ufdl:"application/vnd.ufdl",ulx:"application/x-glulx",umj:"application/vnd.umajin",unityweb:"application/vnd.unity",uoml:"application/vnd.uoml+xml",uri:"text/uri-list",uris:"text/uri-list",urls:"text/uri-list",ustar:"application/x-ustar",utz:"application/vnd.uiq.theme",uu:"text/x-uuencode",uva:"audio/vnd.dece.audio",uvd:"application/vnd.dece.data",uvf:"application/vnd.dece.data",uvg:"image/vnd.dece.graphic",uvh:"video/vnd.dece.hd",uvi:"image/vnd.dece.graphic",uvm:"video/vnd.dece.mobile",uvp:"video/vnd.dece.pd",uvs:"video/vnd.dece.sd",uvt:"application/vnd.dece.ttml+xml",uvu:"video/vnd.uvvu.mp4",uvv:"video/vnd.dece.video",uvva:"audio/vnd.dece.audio",uvvd:"application/vnd.dece.data",uvvf:"application/vnd.dece.data",uvvg:"image/vnd.dece.graphic",uvvh:"video/vnd.dece.hd",uvvi:"image/vnd.dece.graphic",uvvm:"video/vnd.dece.mobile",uvvp:"video/vnd.dece.pd",uvvs:"video/vnd.dece.sd",uvvt:"application/vnd.dece.ttml+xml",uvvu:"video/vnd.uvvu.mp4",uvvv:"video/vnd.dece.video",uvvx:"application/vnd.dece.unspecified",uvvz:"application/vnd.dece.zip",uvx:"application/vnd.dece.unspecified",uvz:"application/vnd.dece.zip",vcard:"text/vcard",vcd:"application/x-cdlink",vcf:"text/x-vcard",vcg:"application/vnd.groove-vcard",vcs:"text/x-vcalendar",vcx:"application/vnd.vcx",vis:"application/vnd.visionary",viv:"video/vnd.vivo",vob:"video/x-ms-vob",vor:"application/vnd.stardivision.writer",vox:"application/x-authorware-bin",vrml:"model/vrml",vsd:"application/vnd.visio",vsf:"application/vnd.vsf",vss:"application/vnd.visio",vst:"application/vnd.visio",vsw:"application/vnd.visio",vtu:"model/vnd.vtu",vxml:"application/voicexml+xml",w3d:"application/x-director",wad:"application/x-doom",wasm:"application/wasm",wav:"audio/x-wav",wax:"audio/x-ms-wax",wbmp:"image/vnd.wap.wbmp",wbs:"application/vnd.criticaltools.wbs+xml",wbxml:"application/vnd.wap.wbxml",wcm:"application/vnd.ms-works",wdb:"application/vnd.ms-works",wdp:"image/vnd.ms-photo",weba:"audio/webm",webm:"video/webm",webmanifest:"application/manifest+json",webp:"image/webp",wg:"application/vnd.pmi.widget",wgt:"application/widget",wks:"application/vnd.ms-works",wm:"video/x-ms-wm",wma:"audio/x-ms-wma",wmd:"application/x-ms-wmd",wmf:"application/x-msmetafile",wml:"text/vnd.wap.wml",wmlc:"application/vnd.wap.wmlc",wmls:"text/vnd.wap.wmlscript",wmlsc:"application/vnd.wap.wmlscriptc",wmv:"video/x-ms-wmv",wmx:"video/x-ms-wmx",wmz:"application/x-ms-wmz",woff:"application/x-font-woff",woff2:"font/woff2",wpd:"application/vnd.wordperfect",wpl:"application/vnd.ms-wpl",wps:"application/vnd.ms-works",wqd:"application/vnd.wqd",wri:"application/x-mswrite",wrl:"model/vrml",wsdl:"application/wsdl+xml",wspolicy:"application/wspolicy+xml",wtb:"application/vnd.webturbo",wvx:"video/x-ms-wvx",x32:"application/x-authorware-bin",x3d:"model/x3d+xml",x3db:"model/x3d+binary",x3dbz:"model/x3d+binary",x3dv:"model/x3d+vrml",x3dvz:"model/x3d+vrml",x3dz:"model/x3d+xml",xaml:"application/xaml+xml",xap:"application/x-silverlight-app",xar:"application/vnd.xara",xbap:"application/x-ms-xbap",xbd:"application/vnd.fujixerox.docuworks.binder",xbm:"image/x-xbitmap",xdf:"application/xcap-diff+xml",xdm:"application/vnd.syncml.dm+xml",xdp:"application/vnd.adobe.xdp+xml",xdssc:"application/dssc+xml",xdw:"application/vnd.fujixerox.docuworks",xenc:"application/xenc+xml",xer:"application/patch-ops-error+xml",xfdf:"application/vnd.adobe.xfdf",xfdl:"application/vnd.xfdl",xht:"application/xhtml+xml",xhtml:"application/xhtml+xml",xhvml:"application/xv+xml",xif:"image/vnd.xiff",xla:"application/vnd.ms-excel",xlam:"application/vnd.ms-excel.addin.macroenabled.12",xlc:"application/vnd.ms-excel",xlf:"application/x-xliff+xml",xlm:"application/vnd.ms-excel",xls:"application/vnd.ms-excel",xlsb:"application/vnd.ms-excel.sheet.binary.macroenabled.12",xlsm:"application/vnd.ms-excel.sheet.macroenabled.12",xlsx:"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",xlt:"application/vnd.ms-excel",xltm:"application/vnd.ms-excel.template.macroenabled.12",xltx:"application/vnd.openxmlformats-officedocument.spreadsheetml.template",xlw:"application/vnd.ms-excel",xm:"audio/xm",xml:"application/xml",xo:"application/vnd.olpc-sugar",xop:"application/xop+xml",xpi:"application/x-xpinstall",xpl:"application/xproc+xml",xpm:"image/x-xpixmap",xpr:"application/vnd.is-xpr",xps:"application/vnd.ms-xpsdocument",xpw:"application/vnd.intercon.formnet",xpx:"application/vnd.intercon.formnet",xsl:"application/xml",xslt:"application/xslt+xml",xsm:"application/vnd.syncml+xml",xspf:"application/xspf+xml",xul:"application/vnd.mozilla.xul+xml",xvm:"application/xv+xml",xvml:"application/xv+xml",xwd:"image/x-xwindowdump",xyz:"chemical/x-xyz",xz:"application/x-xz",yang:"application/yang",yin:"application/yin+xml",z1:"application/x-zmachine",z2:"application/x-zmachine",z3:"application/x-zmachine",z4:"application/x-zmachine",z5:"application/x-zmachine",z6:"application/x-zmachine",z7:"application/x-zmachine",z8:"application/x-zmachine",zaz:"application/vnd.zzazz.deck+xml",zip:"application/zip",zir:"application/vnd.zul",zirz:"application/vnd.zul",zmm:"application/vnd.handheld-entertainment+xml"},B.f4,A.b1("ct<m,m>"))
B.hO=A.b4("bT")
B.hP=A.b4("cz")
B.hQ=A.b4("cD")
B.hR=A.b4("cG")
B.hS=A.b4("c7")
B.hT=A.b4("c8")
B.hU=A.b4("d0")
B.aN=A.b4("d8")
B.hV=A.b4("d9")
B.hW=A.b4("dh")
B.hX=new A.fc(!0)
B.hY=new A.cg(null,2)})();(function staticFields(){$.j5=null
$.lm=null
$.kR=null
$.kQ=null
$.ms=null
$.mj=null
$.mx=null
$.jA=null
$.jI=null
$.kz=null
$.cj=null
$.dK=null
$.dL=null
$.kv=!1
$.C=B.h
$.am=A.b([],t.hf)
$.ao=A.ar("_config")
$.kt=null
$.lL=!1
$.lM=A.b([A.kB(),A.qM(),A.qR(),A.qS(),A.qT(),A.qU(),A.qV(),A.qW(),A.qX(),A.qY(),A.qN(),A.qO(),A.qP(),A.qQ(),A.kB(),A.kB()],A.b1("p<e(aV,e,e)>"))
$.jU=null
$.O=null
$.h8=A.ar("_eLut")
$.ac=null
$.bf=!1})();(function lazyInitializers(){var s=hunkHelpers.lazyFinal,r=hunkHelpers.lazy
s($,"r3","mC",()=>A.q3("_$dart_dartClosure"))
s($,"rX","kH",()=>B.h.eV(new A.jL(),A.b1("ax<K>")))
s($,"rb","mE",()=>A.aU(A.i7({
toString:function(){return"$receiver$"}})))
s($,"rc","mF",()=>A.aU(A.i7({$method$:null,
toString:function(){return"$receiver$"}})))
s($,"rd","mG",()=>A.aU(A.i7(null)))
s($,"re","mH",()=>A.aU(function(){var $argumentsExpr$="$arguments$"
try{null.$method$($argumentsExpr$)}catch(q){return q.message}}()))
s($,"rh","mK",()=>A.aU(A.i7(void 0)))
s($,"ri","mL",()=>A.aU(function(){var $argumentsExpr$="$arguments$"
try{(void 0).$method$($argumentsExpr$)}catch(q){return q.message}}()))
s($,"rg","mJ",()=>A.aU(A.lH(null)))
s($,"rf","mI",()=>A.aU(function(){try{null.$method$}catch(q){return q.message}}()))
s($,"rk","mN",()=>A.aU(A.lH(void 0)))
s($,"rj","mM",()=>A.aU(function(){try{(void 0).$method$}catch(q){return q.message}}()))
s($,"rt","kD",()=>A.oP())
s($,"rl","mO",()=>new A.ib().$0())
s($,"rm","mP",()=>new A.ia().$0())
s($,"ry","mU",()=>A.nU("^[\\-\\.0-9A-Z_a-z~]*$"))
r($,"rV","mY",()=>new Error().stack!=void 0)
s($,"rx","mT",()=>A.kn(B.I,B.Y,257,286,15))
s($,"rw","mS",()=>A.kn(B.ay,B.w,0,30,15))
s($,"rv","mR",()=>A.kn(null,B.eV,0,19,7))
r($,"rn","fG",()=>A.hE(511))
r($,"ro","jP",()=>A.hE(511))
r($,"rq","jQ",()=>A.li(2041))
r($,"rr","fH",()=>A.li(225))
r($,"rp","af",()=>A.hE(766))
s($,"rK","a1",()=>A.hE(1))
s($,"rL","a7",()=>{var q=$.a1().buffer
A.bO(q,0,null)
q=new Int8Array(q,0)
return q})
s($,"rD","a6",()=>A.nN(1))
s($,"rE","ag",()=>{var q,p=$.a6().buffer
A.bO(p,0,null)
q=B.a.F(p.byteLength-0,2)
return new Int16Array(p,0,q)})
s($,"rF","A",()=>A.nO(1))
s($,"rH","P",()=>{var q,p=$.A().buffer
A.bO(p,0,null)
q=B.a.F(p.byteLength-0,4)
return new Int32Array(p,0,q)})
s($,"rG","bt",()=>A.nr($.A().buffer))
s($,"rB","kF",()=>A.nM(1))
s($,"rC","mW",()=>A.lI($.kF().buffer,0))
s($,"rz","kE",()=>A.nK(1))
s($,"rA","mV",()=>A.lI($.kE().buffer,0))
s($,"rI","kG",()=>A.nZ(1))
s($,"rJ","mX",()=>{var q=$.kG()
return A.ns(q.gd0(q))})
s($,"rU","co",()=>{var q=t.N
return new A.hD(A.J(q,q),A.b([],A.b1("p<r5>")))})
s($,"ra","mD",()=>new A.f7())
s($,"rs","mQ",()=>new A.bL(!0,null,null,null))
s($,"r2","mB",()=>{var q=new A.b8(!1,++$.kC().a,null)
q.f=1
q.a=0
return q})
s($,"r7","kC",()=>new A.hV())})();(function nativeSupport(){!function(){var s=function(a){var m={}
m[a]=1
return Object.keys(hunkHelpers.convertToFastObject(m))[0]}
v.getIsolateTag=function(a){return s("___dart_"+a+v.isolateTag)}
var r="___dart_isolate_tags_"
var q=Object[r]||(Object[r]=Object.create(null))
var p="_ZxYxX"
for(var o=0;;o++){var n=s(p+"_"+o+"_")
if(!(n in q)){q[n]=1
v.isolateTag=n
break}}v.dispatchPropertyName=v.getIsolateTag("dispatch_record")}()
hunkHelpers.setOrUpdateInterceptorsByTag({DOMError:J.ay,MediaError:J.ay,MessageChannel:J.ay,NavigatorUserMediaError:J.ay,OverconstrainedError:J.ay,PositionError:J.ay,GeolocationPositionError:J.ay,ArrayBuffer:A.cV,DataView:A.N,ArrayBufferView:A.N,Float32Array:A.eD,Float64Array:A.eE,Int16Array:A.eF,Int32Array:A.eG,Int8Array:A.eH,Uint16Array:A.eI,Uint32Array:A.cW,Uint8ClampedArray:A.cX,CanvasPixelArray:A.cX,Uint8Array:A.bG,Blob:A.bw,DedicatedWorkerGlobalScope:A.bY,DOMException:A.h_,AbortPaymentEvent:A.i,AnimationEvent:A.i,AnimationPlaybackEvent:A.i,ApplicationCacheErrorEvent:A.i,BackgroundFetchClickEvent:A.i,BackgroundFetchEvent:A.i,BackgroundFetchFailEvent:A.i,BackgroundFetchedEvent:A.i,BeforeInstallPromptEvent:A.i,BeforeUnloadEvent:A.i,BlobEvent:A.i,CanMakePaymentEvent:A.i,ClipboardEvent:A.i,CloseEvent:A.i,CompositionEvent:A.i,CustomEvent:A.i,DeviceMotionEvent:A.i,DeviceOrientationEvent:A.i,ErrorEvent:A.i,ExtendableEvent:A.i,ExtendableMessageEvent:A.i,FetchEvent:A.i,FocusEvent:A.i,FontFaceSetLoadEvent:A.i,ForeignFetchEvent:A.i,GamepadEvent:A.i,HashChangeEvent:A.i,InstallEvent:A.i,KeyboardEvent:A.i,MediaEncryptedEvent:A.i,MediaKeyMessageEvent:A.i,MediaQueryListEvent:A.i,MediaStreamEvent:A.i,MediaStreamTrackEvent:A.i,MIDIConnectionEvent:A.i,MIDIMessageEvent:A.i,MouseEvent:A.i,DragEvent:A.i,MutationEvent:A.i,NotificationEvent:A.i,PageTransitionEvent:A.i,PaymentRequestEvent:A.i,PaymentRequestUpdateEvent:A.i,PointerEvent:A.i,PopStateEvent:A.i,PresentationConnectionAvailableEvent:A.i,PresentationConnectionCloseEvent:A.i,ProgressEvent:A.i,PromiseRejectionEvent:A.i,PushEvent:A.i,RTCDataChannelEvent:A.i,RTCDTMFToneChangeEvent:A.i,RTCPeerConnectionIceEvent:A.i,RTCTrackEvent:A.i,SecurityPolicyViolationEvent:A.i,SensorErrorEvent:A.i,SpeechRecognitionError:A.i,SpeechRecognitionEvent:A.i,SpeechSynthesisEvent:A.i,StorageEvent:A.i,SyncEvent:A.i,TextEvent:A.i,TouchEvent:A.i,TrackEvent:A.i,TransitionEvent:A.i,WebKitTransitionEvent:A.i,UIEvent:A.i,VRDeviceEvent:A.i,VRDisplayEvent:A.i,VRSessionEvent:A.i,WheelEvent:A.i,MojoInterfaceRequestEvent:A.i,ResourceProgressEvent:A.i,USBConnectionEvent:A.i,IDBVersionChangeEvent:A.i,AudioProcessingEvent:A.i,OfflineAudioCompletionEvent:A.i,WebGLContextEvent:A.i,Event:A.i,InputEvent:A.i,SubmitEvent:A.i,EventTarget:A.aN,File:A.c_,MessageEvent:A.aT,MessagePort:A.bc,ServiceWorkerGlobalScope:A.bm,SharedWorkerGlobalScope:A.bm,WorkerGlobalScope:A.bm})
hunkHelpers.setOrUpdateLeafTags({DOMError:true,MediaError:true,MessageChannel:true,NavigatorUserMediaError:true,OverconstrainedError:true,PositionError:true,GeolocationPositionError:true,ArrayBuffer:true,DataView:true,ArrayBufferView:false,Float32Array:true,Float64Array:true,Int16Array:true,Int32Array:true,Int8Array:true,Uint16Array:true,Uint32Array:true,Uint8ClampedArray:true,CanvasPixelArray:true,Uint8Array:false,Blob:false,DedicatedWorkerGlobalScope:true,DOMException:true,AbortPaymentEvent:true,AnimationEvent:true,AnimationPlaybackEvent:true,ApplicationCacheErrorEvent:true,BackgroundFetchClickEvent:true,BackgroundFetchEvent:true,BackgroundFetchFailEvent:true,BackgroundFetchedEvent:true,BeforeInstallPromptEvent:true,BeforeUnloadEvent:true,BlobEvent:true,CanMakePaymentEvent:true,ClipboardEvent:true,CloseEvent:true,CompositionEvent:true,CustomEvent:true,DeviceMotionEvent:true,DeviceOrientationEvent:true,ErrorEvent:true,ExtendableEvent:true,ExtendableMessageEvent:true,FetchEvent:true,FocusEvent:true,FontFaceSetLoadEvent:true,ForeignFetchEvent:true,GamepadEvent:true,HashChangeEvent:true,InstallEvent:true,KeyboardEvent:true,MediaEncryptedEvent:true,MediaKeyMessageEvent:true,MediaQueryListEvent:true,MediaStreamEvent:true,MediaStreamTrackEvent:true,MIDIConnectionEvent:true,MIDIMessageEvent:true,MouseEvent:true,DragEvent:true,MutationEvent:true,NotificationEvent:true,PageTransitionEvent:true,PaymentRequestEvent:true,PaymentRequestUpdateEvent:true,PointerEvent:true,PopStateEvent:true,PresentationConnectionAvailableEvent:true,PresentationConnectionCloseEvent:true,ProgressEvent:true,PromiseRejectionEvent:true,PushEvent:true,RTCDataChannelEvent:true,RTCDTMFToneChangeEvent:true,RTCPeerConnectionIceEvent:true,RTCTrackEvent:true,SecurityPolicyViolationEvent:true,SensorErrorEvent:true,SpeechRecognitionError:true,SpeechRecognitionEvent:true,SpeechSynthesisEvent:true,StorageEvent:true,SyncEvent:true,TextEvent:true,TouchEvent:true,TrackEvent:true,TransitionEvent:true,WebKitTransitionEvent:true,UIEvent:true,VRDeviceEvent:true,VRDisplayEvent:true,VRSessionEvent:true,WheelEvent:true,MojoInterfaceRequestEvent:true,ResourceProgressEvent:true,USBConnectionEvent:true,IDBVersionChangeEvent:true,AudioProcessingEvent:true,OfflineAudioCompletionEvent:true,WebGLContextEvent:true,Event:false,InputEvent:false,SubmitEvent:false,EventTarget:false,File:true,MessageEvent:true,MessagePort:true,ServiceWorkerGlobalScope:true,SharedWorkerGlobalScope:true,WorkerGlobalScope:false})
A.U.$nativeSuperclassTag="ArrayBufferView"
A.du.$nativeSuperclassTag="ArrayBufferView"
A.dv.$nativeSuperclassTag="ArrayBufferView"
A.bd.$nativeSuperclassTag="ArrayBufferView"
A.dw.$nativeSuperclassTag="ArrayBufferView"
A.dx.$nativeSuperclassTag="ArrayBufferView"
A.aj.$nativeSuperclassTag="ArrayBufferView"})()
Function.prototype.$0=function(){return this()}
Function.prototype.$1=function(a){return this(a)}
Function.prototype.$2=function(a,b){return this(a,b)}
Function.prototype.$3=function(a,b,c){return this(a,b,c)}
Function.prototype.$4=function(a,b,c,d){return this(a,b,c,d)}
Function.prototype.$1$1=function(a){return this(a)}
Function.prototype.$5=function(a,b,c,d,e){return this(a,b,c,d,e)}
Function.prototype.$6=function(a,b,c,d,e,f){return this(a,b,c,d,e,f)}
convertAllToFastObject(w)
convertToFastObject($);(function(a){if(typeof document==="undefined"){a(null)
return}if(typeof document.currentScript!="undefined"){a(document.currentScript)
return}var s=document.scripts
function onLoad(b){for(var q=0;q<s.length;++q)s[q].removeEventListener("load",onLoad,false)
a(b.target)}for(var r=0;r<s.length;++r)s[r].addEventListener("load",onLoad,false)})(function(a){v.currentScript=a
var s=A.qf
if(typeof dartMainRunner==="function")dartMainRunner(s,[])
else s([])})})()
//# sourceMappingURL=image_worker.dart.js.map
