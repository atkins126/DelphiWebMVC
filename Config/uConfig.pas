unit uConfig;

interface

const
  __APP__ = '';                               // Ӧ������ ,�ɵ�������Ŀ¼ʹ��
  template = 'view';                        // ģ���Ŀ¼
  template_type = '.html';                  // ģ���ļ�����
  roule_suffix = '.html';                     // α��̬��׺�ļ���
  session_start = true;                     // ����session
  session_timer = 30;                        // session����ʱ�����
  config = 'resources/config.json';         // �����ļ���ַ
  mime = 'resources/mime.json';             // mime�����ļ���ַ
  package_config = 'resources/package.json';                // bpl�������ļ�
  bpl_Reload_timer = 5;                                     // bpl�����ʱ���� Ĭ��5��
  bpl_unload_timer = 10;                                    // bpl��ж��ʱ���� Ĭ��10�룬�����°���ȴ�10��ж�ؾɰ�
  open_package = false;                                      // ʹ�� bpl������ģʽ
  open_log = true;                          // ������־;open_debug=true��������־����UI��ʾ
  open_cache = true;                        // ��������ģʽopen_debug=falseʱ��Ч
  cache_max_age = '315360000';                // ���泬��ʱ����
  open_interceptor = true;                 // ����������
  document_charset = 'utf-8';               // �ַ���
  password_key = '';                        // �����ļ���Կ����,Ϊ��ʱ��������Կ,��ϼ��ܹ���ʹ��.
  show_sql = false;                            //��־��ӡsql
  open_debug = false;                       // ������ģʽ���湦�ܽ���ʧЧ,����ǰ���������������
implementation

end.

