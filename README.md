# mt_plugin_AmpConvert

Movable Type�pAMP�y�[�W�쐬�v���O�C��
====

ARK-Web/mt_plugin_AmpConvert - Movable Type�ł�AMP�Ή��y�[�W�������x������v���O�C���ł��B

### �T�v
* img �^�O�� amp-img �ɕϊ����A����ɉ摜�T�C�Y�������s�����Ă���t������
* YouTube���ߍ��݃R�[�h�� amp-youtube �^�O�ɕϊ�����
* �]���ȃC�����C��CSS�̋L�q����������

�Ƃ������ϊ����s���܂��B

### ����
���̕ϊ����s���܂��B

#### 1. �C�����C�� style �̏���

`<mt:AmpConvert>�`</mt:AmpConvert>` ���� �S�ẴC�����C��CSS�̋L�q�ustyle="XXX"�v���폜����܂��B


#### 2. img �� amp-img�֕ϊ�

�S�Ă� `<img>`�^�O���A`<amp-img>` �^�O�ɒu�������܂��B

**amp-img��width,height�����ݒ�**

����img�^�O�� width �܂��� height �������L�q����Ă��Ȃ��ꍇ�ɁA�摜�̃T�C�Y���擾���āAamp-img �Ɏ����ݒ肵�܂�(�p�����[�^�̎w��ŃI�t�ɂł��܂�)�B

�Ȃ�炩�̗��R�ŉ摜���擾�ł��Ȃ������ꍇ�́Awidth,height�̎����ݒ�͍s��ꂸ�AMT���O�Ƀ��O���c���܂��B

#### 3. YouTube�̖��ߍ��݃R�[�h �� amp-youtube �ɕϊ�

iframe �^�O�̂����Asrc���uhttps://www.youtube.com/embed/�`�v�̂��̂��ϊ��ΏۂƂȂ�܂��B

�^�O `<iframe>�`</iframe>` �� `<amp-youtube>�`</amp-youtube>`�ɕϊ�����A�p�����[�^�ɂ��Ă͎��̃��[���ŕϊ�����܂��B

* data-videoid
  * https://www.youtube.com/embed/XXXX �́uXXXX�v��data-videoid�ɐݒ肳���
  * layout: �uresponsive�v���ݒ肳��܂�
  * src: �폜����܂�
  * frameborder: �폜����܂�
  * allowfullscreen: �폜����܂�

����YouTube���ߍ��݃R�[�h

	<iframe
		width="560"
		height="315"
		src="https://www.youtube.com/embed/RDDxlJld2AxSo" 
		frameborder="0"
		allowfullscreen>
	</iframe>

��
amp-youtube �ϊ���

	<amp-youtube
		data-videoid="RDDxlJld2AxSo" 
		layout="responsive" 
		width="560"
		height="315"
	</amp-youtube>
