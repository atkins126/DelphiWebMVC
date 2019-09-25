unit MVC.Config;

interface

type
  TConfig = record
    __APP__: string;                               // Ӧ������ ,�ɵ�������Ŀ¼ʹ��
    __WebRoot__:string;                     //��Ŀ¼
    template: string;                     // ģ���Ŀ¼
    template_type: string;                  // ģ���ļ�����
    roule_suffix: string;                     // α��̬��׺�ļ���
    session_name: string;
    session_start: Boolean;                     // ����session
    session_timer: Integer;                        // session����ʱ�����
    config: string;         // �����ļ���ַ
    mime: string;             // mime�����ļ���ַ
    package_config: string;                // bpl�������ļ�
    bpl_Reload_timer: Integer;                                     // bpl�����ʱ���� Ĭ��5��
    bpl_unload_timer: Integer;                                    // bpl��ж��ʱ���� Ĭ��10�룬�����°���ȴ�10��ж�ؾɰ�
    open_package: Boolean;                                      // ʹ�� bpl������ģʽ
    open_log: Boolean;                          // ������־;open_debug=true��������־����UI��ʾ
    open_cache: Boolean;                        // ��������ģʽopen_debug=falseʱ��Ч
    cache_max_age: string;                // ���泬��ʱ����
    open_interceptor: Boolean;                 // ����������
    document_charset: string;               // �ַ���
    password_key: string;                        // �����ļ���Կ����,Ϊ��ʱ��������Կ,��ϼ��ܹ���ʹ��.
    show_sql: Boolean;                            //��־��ӡsql
    open_debug: Boolean;                       // ������ģʽ���湦�ܽ���ʧЧ,����ǰ���������������
    Error404:string;
    Error500:string;
		JsonToLower:boolean;// ����json������Сд��ʽ��ʾ
  end;

var
  Config: TConfig;

implementation

end.

